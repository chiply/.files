(use-package highlight-symbol
  :config
  (setq highlight-symbol-idle-delay 0.05)

  :hook ((sql-mode python-mode emacs-lisp-mode yaml-mode jsonian-mode json-mode web-mode shell-mode sh-mode) . highlight-symbol-mode)

  )
