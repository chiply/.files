(use-package bookmark+
  :config
  (defun z-bookmark-create ()
    (interactive)
    (bookmark-set)
    (bmkp-set-lighting-for-this-buffer 'rfringe nil 'auto nil t)
    (bookmark-save))

  :general
  (
   :keymaps 'override
   :prefix "s-b"
   ;;"b" 'bookmark-in-project-jump
   "n" 'z-bookmark-create
   )
  :hook ((org-mode python-ts-mode emacs-lisp-mode)
         . (lambda ()
             (call-interactively 'bmkp-light-bookmarks))))
