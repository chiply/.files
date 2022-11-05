(use-package wgrep
  :config
  (setq wgrep-auto-save-buffer t)

  :general
  (
   :states '(normal visual)
   :keymaps '(wgrep-mode-map)
   "<C-return>" 'wgrep-finish-edit
   )
  )
