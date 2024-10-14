(use-package olivetti
  :config
  (setq-default olivetti-style 'fancy)
  (setq-default olivetti-margin-width 3)
  (setq-default olivetti-body-width 0.5)
  (setq-default olivetti-minimum-body-width 70)

  ;;:hydra
  ;;(defhydra+ hydra-window ()
    ;;("C-o" (lambda () (interactive) (call-interactively 'olivetti-mode)))
    ;;)

  :general
  (
   :keymaps 'hercules-magit-keymap
   "C-o" '(lambda () (interactive) (call-interactively 'olivetti-mode))
   )
  )
