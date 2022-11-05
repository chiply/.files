(use-package highlight-symbol
  :config
  (setq highlight-symbol-idle-delay 0.05)

  :hook ((python-mode emacs-lisp-mode yaml-mode jsonian-mode json-mode web-mode shell-mode) . highlight-symbol-mode)

  )
