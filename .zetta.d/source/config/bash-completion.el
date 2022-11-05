(use-package bash-completion
  :config
  (bash-completion-setup)
  (setq bash-completion-args '("--noediting" "--rcfile" "~/.bashrc"))
  )

(process-send-string "*bash-completion*" "complete -C '/usr/local/bin/aws_completer' aws")

(shell )


