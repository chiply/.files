;;;;;;;;;;;;;;;;;;;; very strange -- something is adding this hook to org-mode, which causes it to break
(remove-hook 'org-mode-hook 'org)
(setq request-storage-directory (expand-file-name ".data/request" user-emacs-directory))
