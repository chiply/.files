(use-package bookmark+
  :ensure (bookmark+
           :fetcher github
           :repo "emacsmirror/bookmark-plus"
           :files (:defaults
                   "*.el")
           :main "bookmark+.el")
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
   "n" 'z-bookmark-create
   )
  :hook ((org-mode python-ts-mode emacs-lisp-mode)
         . (lambda ()
             (call-interactively 'bmkp-light-bookmarks))))
