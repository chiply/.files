(use-package highlight-symbol
  :config
  (setq highlight-symbol-idle-delay 0.05)

  :hook ((sql-mode python-ts-mode emacs-lisp-mode yaml-mode
                   jsonian-mode json-mode web-mode shell-command-mode sh-mode
                   lark-mode makefile-mode) .
                   highlight-symbol-mode)

  )
