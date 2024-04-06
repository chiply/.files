;;;;;;;;;;;;;;;;;;;; very strange -- something is adding this hook to org-mode, which causes it to break
(remove-hook 'org-mode-hook 'org)
(setq request-storage-directory (expand-file-name ".data/request" user-emacs-directory))

;; not sure why this isn't working in embark -- may not work here either, i think something overrides this
;; maybe which key setup in meow?
(setq prefix-help-command #'embark-prefix-help-command)
