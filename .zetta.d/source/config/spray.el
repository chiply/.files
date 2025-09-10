(use-package spray
  ;; NOTE doesn't work with evil, which is why I have the custom functions belowkj
  :ensure (spray :type git :host github :repo "emacsmirror/spray")
  :commands (z-spray-mode)
  :config
  (defun z-spray-mode ()
    (interactive)
    (evil-emacs-state)
    (text-scale-increase 2.0)
    (spray-mode))

  (defun z-spray-quit ()
    (interactive)
    (evil-normal-state)
    (spray-quit))

  :general
  (
   :keymaps 'spray-mode-map
   "q" 'z-spray-quit
   "C-g" 'z-spray-quit
   )

  )



