(use-package typescript-ts-mode
  :straight (:type built-in)
  :config
  (add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-ts-mode))
  )
