(use-package simple
  :ensure nil ;; builtin
  :commands (shell-command async-shell-command)
  :init
  (setq kill-ring-max 10000)
  :config

  ;; NOTE commenting out to prevent shell-command-to-string from
  ;; writing to history
  ;;(advice-add 'shell-command :after
  ;;(lambda (&rest args)
  ;;(append-to-zsh-history (car args))))
  (advice-add 'async-shell-command :after
              (lambda (&rest args)
                (append-to-zsh-history (car args))))

  (defun z-shell-command ()
    (interactive)
    (let ((shell-command-history (parse-zsh-history "~/.zsh_history")))
      (call-interactively 'shell-command)))

  (defun z-async-shell-command ()
    (interactive)
    (let ((shell-command-history (parse-zsh-history "~/.zsh_history")))
      (call-interactively 'async-shell-command)))

  :general
  (
   :keymaps 'override
   "M-&" 'z-async-shell-command
   "M-!" 'z-shell-command
   )
  
  )
