(use-package embark
  :demand t
  :config
  (defun embark-act-noquit ()
    "Run action but don't quit the minibuffer afterwards."
    (interactive)
    (let ((embark-quit-after-action nil))
      (embark-act)))

  (setq embark-indicators '(embark-highlight-indicator embark-minimal-indicator))

  ;; note this also affects which-key
  (setq prefix-help-command #'embark-prefix-help-command)

  :display
  (define-key embark-general-map (kbd "!") 'hlt-highlight-symbol)
  (define-key embark-general-map (kbd "C-!") 'hlt-unhighlight-symbol)

  :general
  (
   :keymaps '(override)
   :states '(normal visual)
   "C-." 'embark-act
   "C->" 'embark-act-noquit)
  (
   :keymaps '(vertico-map)
   "C-." 'embark-act
   "C->" 'embark-act-noquit))



