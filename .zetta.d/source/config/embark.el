(use-package embark
  :demand t
  :config
  (defun embark-act-noquit ()
    "Run action but don't quit the minibuffer afterwards."
    (interactive)
    (let ((embark-quit-after-action nil))
      (embark-act)))

  ;; when displaying in side buffer
  (setq embark-verbose-indicator-display-action
        '((display-buffer-in-side-window)
          (side . right)
          (slot . 99)
          (width . 0.25)
          (height . 0.3)))

  (setq embark-indicators
        '(
          ;;embark-which-key-indicator
          embark-highlight-indicator
          embark-minimal-indicator
          ;;embark-isearch-highlight-indicator
          ))

  ;; note this will also affect which key
  (setq prefix-help-command #'embark-prefix-help-command)


  :display
  (z-side "^\\*Embark Collect*" 'right -1 0.25)
  (z-side "^\\*Embark Export Variables*" 'right -1 0.25)
  ;; not setting export bc theoretically it is in a specific mode
  ;; (z-side "^\\*Embark Export*" 'top)


  ;; how to add a action to embark-file-map
  ;;(defun foobar () (interactive) (message "foobar"))
  (define-key embark-general-map (kbd "!") 'highlight-symbol-at-point)

  ;; inspect defined maps embark-keymap-alist, note 3rd party packages
  ;; add to this!

  :general
  (
   :keymaps '(override)
   :states '(normal visual)
   "C-." 'embark-act
   "C->" 'embark-act-noquit
   )
  (
   :keymaps '(vertico-map)
   "C-." 'embark-act
   "C->" 'embark-act-noquit
   )
  )

