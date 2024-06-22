(z-side :regex "^\\*blacken-error*" :side 'top :slot 1)
(z-side :regex "^\\*compilation*" :side 'top :slot 1)
;; note this can't have the backslashes...
(z-side :regex "compilation-mode" :side 'top :slot 1) 
(z-side :regex "^\\*Async*" :side 'top :slot 1)
(z-side :regex "shell-command-mode" :side 'top :slot 1)
(z-side :regex "^\\*Shell*" :side 'top :slot 3)
(z-side :regex "\\magit-process-mode" :side 'top :slot 1)
(z-side :regex "^\\*Messages*" :side 'bottom :slot 3)


(setq visual-line-fringe-indicators '(nil top-right-angle))

;;;;(z-side "\\calendar-mode" 'top 1)
;;;;(z-side "\\occur-mode" 'right -1 0.2)
;;;;(z-side "\\grep-mode" 'right -1 0.25)
;;(add-to-list
 ;;'display-buffer-alist
 ;;`(,(z-soda-mode-name "\\org-mode")
   ;;(display-buffer-no-window)
   ;;)
 ;;nil
 ;;)
;;
;;
;;;;(z-side "\\xref--xref-buffer-mode" 'right -1 0.25)
;;
;;(add-hook 'grep-mode-hook '(lambda () (toggle-truncate-lines 1)))
;;(add-hook 'occur-mode-hook '(lambda () (text-scale-set -2)))
;;(add-hook 'grep-mode-hook '(lambda () (text-scale-set -2)))
;;
;;;;(z-side "^\\*Apropos*" 'right)
;;;;(z-side "^\\*Warnings*" 'top)
;;;;(z-side "^\\*Backtrace*" 'top)
;;;;(z-side "^\\*sqls results*" 'top)
;;;;(z-side "^\\*info*" 'bottom)
;;;;(z-side "^\\*Help*" 'right)
;;;;(z-side "^\\*helpful*" 'right)
;;
;;;; makes things less cluttered

