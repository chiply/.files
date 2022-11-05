(use-package jsonian
  :general
  (
   :states '(normal visual insert)
   :keymaps '(jsonian-mode-map)
   "C-c C-j" 'jsonian-find
   )
  :hook (json-mode . jsonian-mode)
  )
