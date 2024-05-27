(use-package bookmark
  :straight nil
  :demand t

  :config
  (setq bookmark-fringe-mark 'bookmark-mark)
  (setq bookmark-save-flag t)

  (add-to-list 'desktop-globals-to-save 'bookmark-alist)

  :display
  ;;(z-side "^\\*Bookmark List*" 'right -10)
  ;;(z-side "^\\*Embark Export Bookmarks*" 'right -10)

  :general
  (
   :keymaps 'override
   :prefix "s-b"
   "B" '(lambda () (interactive)
          (bookmark-jump
           (bookmark-get-bookmark "org-capture-last-stored")))
   "N" '(lambda () (interactive)
          (bookmark-set)
          (bmkp-set-lighting-for-this-buffer 'rfringe nil 'auto nil t)
          (bookmark-save)
          )
   )
  )



