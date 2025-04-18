(use-package vertico-posframe
  :config
  ;;(vertico-posframe-mode 1)
  (setq vertico-posframe-parameters
        '((left-fringe . 8)
          (right-fringe . 8)))
  ;; TODO compute this dynamically
  (setq vertico-posframe-width 180)
  (setq vertico-posframe-height nil))

(use-package vertico
  ;;:straight (:files (:defaults "extensions/*"))

  :init
  (vertico-mode 1)
  (vertico-mouse-mode 1)
  (vertico-flat-mode 1)
  (vertico-multiform-mode 1)

  ;; NOTE experimenting with this for now.
  (setq vertico-multiform-commands
        '((z-magit-project
           posframe
           ;; NEED to do both here
           (vertico-flat-mode . -1)
           (vertico-vertical-mode . 1))
          (t flat)))

  (setq
   vertico-buffer-hide-prompt nil
   vertico-cycle t
   vertico-resize nil ;; avoid moving prompt while typing
   vertico-grid-max-columns 10
   vertico-buffer-display-action '(display-buffer-in-side-window
                                   (side . right)
                                   (window-width . 0.25)))

  ;; this is super super hacky and bizarre... but it's the only way I
  ;; can get this to work

  ;; only works when called from z-vertico-IS
  ;; IS for intellisense
  (setq z-vertico-IS-help-flag nil)
  (setq z-vertico-IS-find-flag nil)

  (defun z-vertico-IS-help ()
    (interactive)
    (setq z-vertico-IS-help-flag t)
    (vertico-exit)
    (z-soda-create-and-display-term))

  (defun z-vertico-IS-find ()
    (interactive)
    (setq z-vertico-IS-find-flag t)
    (vertico-exit))

  (defun z-vertico-IS ()
    (interactive)
    (when (not (or
                (string= major-mode "emacs-lisp-mode")
                (string= major-mode "lisp-interaction-mode")
                (string= major-mode "lisp-mode")
                (string= major-mode "lisp-data-mode")))
      (unless (and (boundp 'lsp-mode) lsp-mode)
        (lsp)))
    (let* ((completion-in-region-function 'consult-completion-in-region)
           ;; this prevents sorting, which can cause vertico repeat to
           ;; yield a different state!  We actually don't /care about/
           ;; sortiing when usinig completion at poiint
           (vertico-sort-function nil)
           (pt (point))
           (linetxt (buffer-substring
                     (line-beginning-position) (line-end-position))))
      (if (and (boundp 'corfu--candidates) corfu--candidates)
          (corfu-quit))
      (completion-at-point)
      (when z-vertico-IS-help-flag
        (if (or
             (string= major-mode "emacs-lisp-mode")
             (string= major-mode "lisp-interaction-mode")
             (string= major-mode "lisp-mode")
             (string= major-mode "lisp-data-mode"))
            (z-helpful-at-point) 
          (lsp-describe-thing-at-point-1))
        (progn (beginning-of-line) (kill-line))
        (progn (insert linetxt) (goto-char pt))
        (setq z-vertico-IS-help-flag nil)
        (call-interactively 'vertico-repeat)) 
      (when z-vertico-IS-find-flag
        (if (or
             (string= major-mode "emacs-lisp-mode")
             (string= major-mode "lisp-interaction-mode")
             (string= major-mode "lisp-mode")
             (string= major-mode "lisp-data-mode"))
            ;; LEFT OFF -- need to refine these functions
            ;; what if definition is in the same buffer... maybe the
            ;; way we use let will inform this
            (evil-goto-definition-1) 
          (lsp-find-definition-1))
        (z-vertico-IS-find)
        (progn (beginning-of-line) (kill-line))
        (progn (insert linetxt) (goto-char pt))
        (setq z-vertico-IS-find-flag nil)
        (call-interactively 'vertico-repeat))))

  (defun my/vertico-quick-embark (&optional arg)
    "Embark on candidate using quick keys."
    (interactive)
    (when (vertico-quick-jump)
      (embark-act arg)))

  :general
  (:keymaps 'override
            "s-V" 'vertico-repeat)

  (:keymaps 'vertico-map
            ;; embark-select
            "C-SPC" 'embark-select
            
            ;; intellisesne
            "C-S-h" 'z-vertico-IS-help
            "C-S-d" 'z-vertico-IS-find
            "C-d" 'consult-dir
            ;; navigation
            "C-j" 'vertico-next
            "C-k" 'vertico-previous
            "C-S-j" 'vertico-scroll-down
            "C-S-k" 'vertico-scroll-up
            "s-j" 'vertico-next-group
            "s-k" 'vertico-previous-group
            ;; yanking
            "C-y" 'yank 
            "<C-return>" 'vertico-exit-input
            ;; avy-like quick selection
            "C-'" 'vertico-quick-exit
            "C-\"" 'my/vertico-quick-embark
            ;; editing prompt
            "C-S-k" 'kill-line
            ;; switching states
            "M-V" 'vertico-multiform-vertical
            "M-R" 'vertico-multiform-reverse
            "M-G" 'vertico-multiform-grid
            "M-F" 'vertico-multiform-flat
            "M-U" 'vertico-multiform-unobtrusive
            ;; save and suspend
            ;;"M-C" 'vertico-save
            "M-S" 'vertico-suspend
            )

  (
   :keymaps 'override
   "M-S" 'vertico-suspend
   )

  ;; remapping for reverse
  (
   :keymaps 'vertico-reverse-map
   "C-k" 'vertico-next
   "C-j" 'vertico-previous
   "C-S-j" 'vertico-scroll-down
   "C-S-k" 'vertico-scroll-up
   "s-k" 'vertico-next-group
   "s-j" 'vertico-previous-group
   )

  ;; remapping for flat
  (
   :keymaps 'vertico-flat-map
   "C-j" 'vertico-next
   "C-k" 'vertico-previous
   "C-S-j" 'vertico-scroll-down
   "C-S-k" 'vertico-scroll-up
   "s-j" 'vertico-next-group
   "s-k" 'vertico-previous-group
   )

  ;; vertico-IS
  (
   :keymaps z-modal-states-insert
   "<C-SPC>" 'z-vertico-IS
   )
  
  :hook (
         ;; needed for vertico repeatt (and therefore the intellisense)
         (minibuffer-setup . vertico-repeat-save)
         )
  )


