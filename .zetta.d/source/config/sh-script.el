(use-package sh-script
  :straight nil
  :demand t
  :config
  ;; for .env files, activate sh-mode
  (add-to-list 'auto-mode-alist '("\\.env\\'" . sh-mode))
  (add-to-list 'auto-mode-alist '("\\.env.template\\'" . sh-mode))
  (add-to-list 'auto-mode-alist '("\\.env.sample\\'" . sh-mode))

  :general
  (
   :states '(normal visual)
   :keymaps '(sh-mode-map)
   "C-e" 'er/expand-region
   )
  
  )
