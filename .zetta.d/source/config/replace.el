(use-package replace
  :straight nil

  :evil
  (evil-set-initial-state 'occur-mode 'normal)
  (evil-set-initial-state 'occur-edit-mode 'normal)

  :general
  (
   :keymaps '(occur-mode-map)
   :states '(normal visual)
   "e" 'occur-edit-mode
   )
  )
