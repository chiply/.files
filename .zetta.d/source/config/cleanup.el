;;;;;;;;;;;;;;;;;;;; very strange -- something is adding this hook to org-mode, which causes it to break
(remove-hook 'org-mode-hook 'org)
(setq request-storage-directory (expand-file-name ".data/request" user-emacs-directory))

;; not sure why this isn't working in embark -- may not work here either, i think something overrides this
;; maybe which key setup in meow?
;;(setq prefix-help-command #'embark-prefix-help-command)

;; truly cannot tell what is ovewriting this upstream but should figure it out
(setq prefix-help-command 'versatile-C-h)

(tab-bar-mode +1)

(if debug-on-error
 (toggle-debug-on-error))
