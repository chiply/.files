(use-package xref
  :straight nil
  :demand t
  :config
  (z-side "^\\*xref*" 'right -1)

  :general
  (
   ;; just override doesn't work
   :keymaps '(override meow-normal-state-keymap evil-normal-state-map)
   "M-." 'xref-find-definitions
   "M-," 'xref-go-back
   ;; note the distinct use from find-definitions.  This is more about
   ;; history traveersal
   "C-M-," 'xref-go-forward
   )

  )
