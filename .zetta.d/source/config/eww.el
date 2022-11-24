(use-package eww
  :straight nil
  :demand t
  :config
  (setq eww-auto-rename-buffer 'title)
  (setq eww-bookmarks-directory (expand-file-name "data/eww" user-emacs-directory))

  (defun z-eww-switch-to-eaf ()
    (interactive)
    (eaf-open-browser (eww-current-url))
    )

  (defun z-eww-follow-link ()
    (interactive)
    (browse-url (thing-at-point 'url))
    )

  :general
  (
   :keymaps '(eww-mode-map)
   "C-&" 'z-eww-switch-to-eaf
   "<return>" 'z-eww-follow-link
   )

  )


