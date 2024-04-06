(use-package bookmark-in-project
  :general
  (
   :keymaps 'override
   :prefix "s-b"
   "b" 'bookmark-in-project-jump
   "n" '(lambda () (interactive)
          (bookmark-in-project-toggle)
          (bmkp-set-lighting-for-this-buffer 'rfringe nil 'auto nil t)
          (bookmark-save)
          )
   )
  )
