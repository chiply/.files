(use-package xref
  :straight nil
  :demand t
  :config
  (z-side "^\\*xref*" 'right -1)

  :general
  (
   :keymaps '(python-ts-mode-map sql-mode-map css-mode-map
                                 sh-mode-map terraform-mode-map dockerfile-mode-map)
   :states '(normal insert visual)
   "M-." 'xref-find-definitions
   "M-," 'xref-go-back
   ;; note the distinct use from find-definitions.  This is more about
   ;; history traveersal
   "C-M-," 'xref-go-forward
   )

  )
