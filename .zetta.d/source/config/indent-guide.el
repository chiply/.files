(use-package indent-guide
  :config
  (setq indent-guide-recursive t)
  (add-to-list 'indent-guide-inhibit-modes 'vterm-mode)
  (indent-guide-global-mode)

  )

