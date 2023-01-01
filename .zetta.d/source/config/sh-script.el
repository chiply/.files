(use-package sh-script
  :straight nil
  :demand t

  :general
  (
   :states '(normal visual)
   :keymaps '(sh-mode-map)
   "C-e" 'er/expand-region
   )
  
  )
