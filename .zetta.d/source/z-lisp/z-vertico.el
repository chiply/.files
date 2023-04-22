;;; z-vertico.el --- Extensions for vertico -*- lexical-binding: t -*-


;;; Code:
(require 'vertico)

(vertico-mode 1)
(vertico-reverse-mode 1)
(vertico-mouse-mode 1)
(vertico-multiform-mode 1)

;; TODO; can't get flat mode to not scroll candidates off screen
;; have tried soluutionoo in readme

(setq
 vertico-buffer-hide-prompt nil
 vertico-cycle t
 vertico-resize t ;; only good when vertico-reverse-mode is enabled
 vertico-grid-max-columns 10
 vertico-buffer-display-action '(display-buffer-in-side-window
                                 (side . right)
                                 (window-width . 0.25))
 ;; ISSUE switchiing from flat to vertical (even reverse) has issues....
 ;; best way for now is to double tab flat-mode to undo it.  This is
 ;; like escaping flat mode
 ;; the ` is needed for the lambdas to run

 ;; TODO: display buffer action per command
   vertico-multiform-commands
   `(
     ;; builtins
     ;; 3rd party
     (helpful-variable grid)
     (helpful-function grid)
     (helpful-command grid)

     (consult-dir reverse)
     (consult-line
      buffer (:not reverse)
      ,(lambda (_) (unless (equal text-scale-mode-amount -2)
                     (text-scale-set -2)))
      (vertico-buffer-display-action
       .
       (display-buffer-in-side-window
        (side . right) (slot . -1) (window-width . 0.25))))

     ;; z-*
     (z-consult-ripgrep
      buffer (:not reverse)
      ,(lambda (_) (unless (equal text-scale-mode-amount -2)
                     (text-scale-set -2)))
      (vertico-buffer-display-action
       .
       (display-buffer-in-side-window
        (side . right) (slot . -1) (window-width . 0.25))))

     )
 )

;; this is super super hacky and bizarre... but it's the only way I
;; can get this to work

;; only works when called from z-vertico-IS
;; IS for intellisense
(setq z-vertico-IS-help-flag nil)
(setq z-vertico-IS-find-flag nil)

;;;###autoload
(defun z-vertico-IS-help ()
  (interactive)
  (setq z-vertico-IS-help-flag t)
  (vertico-exit)
  (z-soda-create-and-display-term)
  )

;;;###autoload
(defun z-vertico-IS-find ()
  (interactive)
  (setq z-vertico-IS-find-flag t)
  (vertico-exit)
  )

;;;###autoload
(defun z-vertico-IS ()
  (interactive)
  (when (not (or
              (string= major-mode "emacs-lisp-mode")
              (string= major-mode "lisp-interaction-mode")
              (string= major-mode "lisp-mode")
              (string= major-mode "lisp-data-mode")
              ))
    (unless (and (boundp 'lsp-mode) lsp-mode)
      (lsp))
    )
  (let* (
         ;; this prevents sorting, which can cause vertico repeat to
         ;; yield a different state!  We actually don't /care about/
         ;; sortiing when usinig completion at poiint
         (vertico-sort-function nil)
         (pt (point))
         (linetxt (buffer-substring
                   (line-beginning-position) (line-end-position))))
    (completion-at-point)
    (when z-vertico-IS-help-flag
      (if (or
           (string= major-mode "emacs-lisp-mode")
           (string= major-mode "lisp-interaction-mode")
           (string= major-mode "lisp-mode")
           (string= major-mode "lisp-data-mode")
           )
          (z-helpful-at-point) 
        (lsp-describe-thing-at-point-1))
      (progn (beginning-of-line) (kill-line))
      (progn (insert linetxt) (goto-char pt))
      (setq z-vertico-IS-help-flag nil)
      (call-interactively 'vertico-repeat)
      ) 
    (when z-vertico-IS-find-flag
      (if (or
           (string= major-mode "emacs-lisp-mode")
           (string= major-mode "lisp-interaction-mode")
           (string= major-mode "lisp-mode")
           (string= major-mode "lisp-data-mode")
           )
          ;; LEFT OFF -- need to refine these functions
          ;; what if definition is in the same buffer... maybe the
          ;; way we use let will inform this
          (evil-goto-definition-1) 
        (lsp-find-definition-1))
      (z-vertico-IS-find)
      (progn (beginning-of-line) (kill-line))
      (progn (insert linetxt) (goto-char pt))
      (setq z-vertico-IS-find-flag nil)
      (call-interactively 'vertico-repeat)
      )
    )
  )

;;;###autoload
(defun my/vertico-quick-embark (&optional arg)
  "Embark on candidate using quick keys."
  (interactive)
  (when (vertico-quick-jump)
    (embark-act arg)))

(add-to-list 'brushup-styles
             '(progn
                (set-face-attribute 'vertico-current nil
                                    :inherit 'lin-yellow)))

(general-define-key
 :keymaps 'override
 "s-V" 'vertico-repeat
 )

(general-define-key
 :keymaps 'vertico-map
 "C-S-h" 'z-vertico-IS-help
 "C-S-d" 'z-vertico-IS-find
 "C-d" 'consult-dir

 "C-j" 'vertico-next
 "C-k" 'vertico-previous
 "C-S-j" 'vertico-scroll-down
 "C-S-k" 'vertico-scroll-up
 "s-j" 'vertico-next-group
 "s-k" 'vertico-previous-group

 "C-y" 'yank 
 "<C-return>" 'vertico-exit-input

 ;; ISSUE:  doesn't work with grid mode
 "C-'" 'vertico-quick-exit
 "C-\"" 'my/vertico-quick-embark


 "C-S-k" 'kill-line

 ;; switching between modes in the buffer
 ;; prefer reverse
 "M-V" 'vertico-multiform-vertical
 "M-R" 'vertico-multiform-reverse
 "M-G" 'vertico-multiform-grid
 "M-F" 'vertico-multiform-flat
 "M-U" 'vertico-multiform-unobtrusive

 "M-S" 'vertico-save

 )

;; remapping for reverse
(general-define-key
 :keymaps 'vertico-reverse-map
 "C-k" 'vertico-next
 "C-j" 'vertico-previous
 "C-S-j" 'vertico-scroll-down
 "C-S-k" 'vertico-scroll-up
 "s-k" 'vertico-next-group
 "s-j" 'vertico-previous-group
 )

;; remapping for flat
(general-define-key
 :keymaps 'vertico-flat-map
 "C-j" 'vertico-next
 "C-k" 'vertico-previous
 "C-S-j" 'vertico-scroll-down
 "C-S-k" 'vertico-scroll-up
 "s-j" 'vertico-next-group
 "s-k" 'vertico-previous-group
 )

;; vertico-IS
(general-define-key
 :states '(insert)
 :keymaps '(python-mode-map
            lisp-interaction-mode-map
            emacs-lisp-mode-map
            lisp-mode-map
            sql-mode-map
            web-mode-map
            js2-mode-map
            rjsx-mode-map
            json-mode-map
            jsonian-mode-map
            text-mode-map
            org-mode-map
            bibtex-mode-map)
 "<C-SPC>" 'z-vertico-IS
 )


(add-hook 'minibuffer-setup-hook 'vertico-repeat-save)

(provide 'z-vertico)
;;; z-vertico.el ends here



