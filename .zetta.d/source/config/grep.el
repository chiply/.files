(use-package grep
  :straight nil
  :demand t
  :config
  (add-to-list 'auto-mode-alist '("\\.grep\\'" . grep-mode))
  )

