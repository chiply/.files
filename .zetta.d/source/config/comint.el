(use-package comint
  :ensure nil
  :demand t
  :config
  (setq comint-input-ring-file-name "~/.zsh_history")
  (add-hook 'shell-mode-hook (lambda () (comint-read-input-ring 'silent)))
  )
