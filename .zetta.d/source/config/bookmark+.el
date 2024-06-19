(use-package bookmark+
  :general
  (
   :keymaps 'override
   :prefix "s-b"
   ;;"b" 'bookmark-in-project-jump
   "n" '(lambda () (interactive)
          (bookmark-set)
          (bmkp-set-lighting-for-this-buffer 'rfringe nil 'auto nil t)
          (bookmark-save))
   )
  :hook ((org-mode python-ts-mode emacs-lisp-mode)
         . (lambda ()
             (call-interactively 'bmkp-light-bookmarks))))
