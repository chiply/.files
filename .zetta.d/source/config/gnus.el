(use-package gnus
  :ensure nil
  :demand t
  :config
  (setq gnus-select-method '(nnnil ""))
  (setq gnus-secondary-select-methods '((nntp "news.gmane.io")))
  (setq gnus-check-new-newsgroups 'ask-server)
  (setq gnus-startup-file (expand-file-name ".newsrc" user-emacs-directory)))
