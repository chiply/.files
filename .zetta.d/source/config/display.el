;;(z-side "^\\*Async*" 'top 1)
;;(z-side "^\\*compilation*" 'top 1)

;; consider having no defaults for these and simply letting other
;; tooling place the windows
;;(z-side "compilation-mode" 'top 1) ;; note this can't have the backslashes...
;;(z-side "shell-mode" 'top 1)
;;(z-side "^\\*Shell*" 'top 3)

(z-side "\\calendar-mode" 'top 1)
(z-side "\\occur-mode" 'right -1 0.2)
(z-side "\\grep-mode" 'right -1 0.25)
(add-to-list
 'display-buffer-alist
 `(,(z-soda-mode-name "\\org-mode")
   (display-buffer-no-window)
   )
 nil
 )


(z-side "\\magit-process-mode" 'top 1 )
(z-side "\\xref--xref-buffer-mode" 'right -1 0.25)

(add-hook 'grep-mode-hook '(lambda () (toggle-truncate-lines 1)))
(add-hook 'occur-mode-hook '(lambda () (text-scale-set -2)))
(add-hook 'grep-mode-hook '(lambda () (text-scale-set -2)))

(z-side "^\\*Apropos*" 'right)
(z-side "^\\*Messages*" 'bottom 3)
(z-side "^\\*Warnings*" 'top)
(z-side "^\\*Backtrace*" 'top)
(z-side "^\\*sqls results*" 'top)
(z-side "^\\*info*" 'bottom)
(z-side "^\\*Help*" 'right)
(z-side "^\\*helpful*" 'right)

;; makes things less cluttered
(setq visual-line-fringe-indicators '(nil top-right-angle))

