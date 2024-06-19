(add-to-list 'default-frame-alist '(fullscreen . maximized)) 
(setq initial-frame-alist (quote ((fullscreen . maximized))))


(defun my/set-transparency (frame)
  (set-frame-parameter frame 'alpha 100))

;; so new frames will not be transparent -- helps distinguish
(add-hook 'after-make-frame-functions 'my/set-transparency)

(defun transparency (value)
  (interactive "nTransparency Value 0 - 100 opaque:")
  (set-frame-parameter (selected-frame) 'alpha value))
(transparency 93)

(defhydra+ hydra-window ()
  ("T" transparency :exit t)
  )

(defhydra+ hydra-window ()
  ("t" hydra-theme/body :exit t)
  )
(defhydra+ hydra-theme ()
  ("w" hydra-window/body :exit t)
  ("T" z-brushup "Brushup" :column "Brushup") 
  )


;;;;;;;;; OLIVETTI
;;(use-package olivetti
;;:config
  ;;;;;;;;;;;;;;;; LEFT OFF - trying to get olivetti width settings
  ;;;;;;;;;;;;;;;; right, need to do this on a per mode basis if
  ;;;;;;;;;;;;;;;; you want to override the default width - 
  ;;;;;;;;;;;;;;;; NOTE OLIVETT-BODY-WIDTH is buffer local, minimum is NOT
;;(defun z-generic-olivetti-mode ()
;;(interactive)
;;(olivetti-mode +1)
;;(setq-local olivetti-body-width 0.80)
;;(setq-local olivetti-minimum-body-width 80)
;;(setq-local olivetti-recall-visual-line-mode-entry-state t)
;;)
;;(add-hook 'org-mode-hook (lambda () (z-generic-olivetti-mode)))
;;(add-hook 'python-ts-mode-hook (lambda () (z-generic-olivetti-mode)))
;;(add-hook 'sql-mode-hook (lambda () (z-generic-olivetti-mode)))
  ;;;;(add-hook 'emacs-lisp-mode-hook (lambda () (z-generic-olivetti-mode)))
;;(add-hook 'web-mode-hook (lambda () (z-generic-olivetti-mode)))
;;(add-hook 'css-mode-hook (lambda () (z-generic-olivetti-mode)))
;;)








;; nott using for now, slows down window switchiing
;;(use-package pulsar
;;:config
;;(customize-set-variable 'pulsar-pulse-functions '(
;;ace-window
;;other-window
;;windmove-right
;;windmove-left
;;))
;;
;;(setq pulsar-face 'pulsar-yellow)
;;(setq pulsar-delay 0.1)
;;
;;(pulsar-global-mode -11)
;;
;;)


;;(use-package solaire-mode
  ;;:config
  ;;(defun z-solaire-fn ()
    ;;(if (window-parameter (get-buffer-window (buffer-base-buffer)) 'window-slot)
        ;;t
      ;;nil))
  ;;(setq solaire-mode-real-buffer-fn 'z-solaire-fn)
  ;;(solaire-global-mode +1)
;;
  ;;:brushup
  ;;(add-to-list 'brushup-styles
               ;;'(progn
                  ;;(set-face-attribute 'solaire-default-face nil
                                      ;;:background brushup-bg-1_0)
                  ;;(set-face-attribute 'solaire-fringe-face nil
                                      ;;:background brushup-bg-1_0)
                  ;;(set-face-attribute 'solaire-line-number-face nil
                                      ;;:background brushup-bg-1_0)
                  ;;(set-face-attribute 'solaire-org-hide-face nil
                                      ;;:background brushup-bg-1_0)
                  ;;(set-face-attribute 'solaire-mode-line-inactive-face nil
                                      ;;:background brushup-bg-1_0)
                  ;;(set-face-attribute 'solaire-mode-line-face nil
                                      ;;:height 140
                                      ;;:underline nil
                                      ;;:overline nil
                                      ;;:box nil
                                      ;;:background brushup-bg
                                      ;;:foreground brushup-fg-3
                                      ;;:underline `(:color ,brushup-fg))))
;;
  ;;:hook (
         ;;(treemacs-mode . solaire-mode)
         ;;(use-package--solaire--post-config . z-brushup)
         ;;)  
  ;;)


(add-hook 'help-mode-hook (lambda () (text-scale-set -2)))
;;(add-hook 'shell-mode-hook (lambda () (text-scale-set -2)))
(add-hook 'Info-mode-hook (lambda () (text-scale-set -2)))
(add-hook 'calendar-mode-hook (lambda () (text-scale-set 2)))
