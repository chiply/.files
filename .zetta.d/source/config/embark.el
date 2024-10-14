(use-package embark
  :ensure (:wait t)
  :demand t
  :config
  (defun embark-act-noquit ()
    "Run action but don't quit the minibuffer afterwards."
    (interactive)
    (let ((embark-quit-after-action nil))
      (embark-act)))

  (setq embark-indicators '(embark-verbose-indicator embark-highlight-indicator embark-minimal-indicator))

  ;; note this also affects which-key
  (setq prefix-help-command #'embark-prefix-help-command)

  (define-key embark-general-map (kbd "C-b") 'z-bookmark-create)

  (define-key embark-general-map (kbd "!") 'symbol-overlay-put)
  (define-key embark-general-map (kbd "C-!") 'symbol-overlay-remove-all)

  :general
  (
   ;; override alone doesn't work here for some reason
   :keymaps (append z-modal-states-non-insert '(override))
   "C-." 'embark-act
   "C->" 'embark-act-all
   )
  (
   :keymaps '(vertico-map)
   "C-." 'embark-act
   "C->" 'embark-act-all
   ))
