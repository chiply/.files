;;; z-tab-line.el --- Extensions for tab-line -*- lexical-binding: t -*-


;;; Code:
(require 'tab-line)

(setq tab-line-switch-cycling t tab-line-close-button-show nil)

;;;###autoload
(defun z-tab-line-close-tab ()
  (interactive)
  (let ((closed-tabs (window-parameter (selected-window) 'closed-tabs)))
    (set-window-parameter
     (selected-window)
     'closed-tabs
     (append closed-tabs (list (current-buffer))))
    (bury-buffer)
    )
  )

(defun z-project-mode-buffers ()
  ;; should be project buffers, for window (union of prev and next)
  (cond
   ;; by-mode; show other buffers in this mode
   ((member
     (symbol-name major-mode)
     '(
       "magit-status-mode"
       "helpful-mode"
       "vterm-mode"
       "eaf-mode"
       ))
    (seq-sort-by
     #'buffer-name #'string<
     (z-soda-list-mode-buffers (symbol-name major-mode))
     )
    )
   ;; grep results
   ((member
     (symbol-name major-mode)
     '(
       "occur-mode"
       "grep-mode"
       ))
    (seq-sort-by
     #'buffer-name #'string<
     (-filter
      (lambda (buf) (and
                     ;; make sure it's note a marker 
                     (bufferp buf)
                     ;; make sure it's project local
                     ;; strange function here bc occur isn't counted
                     ;; in projectile project buffers
                     (or
                      (when (with-current-buffer buf (equal major-mode 'occur-mode))
                        (string-match
                         (projectile-project-root)
                         (with-current-buffer buf default-directory)
                         )
                        )
                      (when (with-current-buffer buf (equal major-mode 'grep-mode))
                        (member buf (projectile-project-buffers)))
                      )
                     ;; make sure it isn't a closed tab
                     (not (member buf (window-parameter (selected-window) 'closed-tabs)))))
      (append
       (z-soda-list-mode-buffers "grep-mode")
       (z-soda-list-mode-buffers "occur-mode")
       ))

     
     )
    )
   ;; buffers in projectile projects, show other project buffers
   ((and (boundp 'projectile-mode) (projectile-project-p))
    (let ((buffers (tab-line-tabs-window-buffers)))
      (seq-sort-by
       #'buffer-name #'string<
       (-filter
        (lambda (buf) (and
                       ;; make sure it's note a marker 
                       (bufferp buf)
                       ;; make sure it's project local
                       (member buf (projectile-project-buffers))
                       ;; make sure it isn't a closed tab
                       (not (member buf (window-parameter (selected-window) 'closed-tabs)))))
        buffers)
       )
      )
    )
   (t
    (let ((buffers (tab-line-tabs-window-buffers)))
      (seq-sort-by
       #'buffer-name #'string<
       buffers
       )
      )
    )
   )


  
  
  )


(defun z-tab-line-tab-name-buffer (buffer &optional _buffers)
  ;; NOTE -- the tab-line does NOT render all-the-icons
  ;; icons... major issue and reason why I don't have icons in the
  ;; tab-line
  (let* (
         (bufnm (buffer-name buffer))
         ;; Here we can shorten verbose names... remember we can
         ;; look at the actual buffer name in the modeline
         (bufnm (string-replace "helpful function" "H" bufnm))
         (bufnm (string-replace "helpful command" "H" bufnm))
         (bufnm (string-replace "helpful variable" "H" bufnm))
         (bufnm (string-replace "Embark Export" "EE" bufnm))
         (bufnm (string-replace "Embark Collect" "EC" bufnm))
         (bufnm (string-replace "Embark Export Grep" "EE G" bufnm))
         (bufnm (string-replace "Embark Export Occur" "EE O" bufnm))
         (bufnm (string-replace "Embark Export Dired" "EE D" bufnm))
         )
    bufnm
    )
  )

(setq tab-line-tab-name-function 'tab-line-tab-name-buffer)
(setq tab-line-tab-name-function 'z-tab-line-tab-name-buffer)
;; need this for the switch tabs funciton
(setq tab-line-tabs-function 'z-project-mode-buffers)


(global-tab-line-mode)

;;:brushup
(add-to-list 'brushup-styles
             '(progn
                (set-face-attribute 'tab-line-tab-current nil
                                    :overline brushup-fg ;; this isn't working
                                    :foreground brushup-fg
                                    :background brushup-bg-1
                                    :box nil
                                    :weight 'normal
                                    :inherit nil
                                    :height 1.0
                                    )
                (set-face-attribute 'tab-line-tab nil
                                    :overline t
                                    :foreground brushup-fg-3
                                    :background brushup-bg-1
                                    :weight 'normal
                                    :box nil
                                    :height 1.0
                                    :inherit nil
                                    )
                (set-face-attribute 'tab-line-tab-inactive nil
                                    :background brushup-bg-1_0
                                    :foreground brushup-bg-6
                                    :box nil
                                    :height 1.0
                                    :overline nil
                                    :inherit nil
                                    )
                (set-face-attribute 'tab-line nil
                                    :background (modus-themes-get-color-value 'bg-blue-nuanced)
                                    :height 1.2
                                    :underline "gray"
                                    ;; basically nil
                                    :overline brushup-bg
                                    :box nil
                                    )
                )
             )


(general-define-key
 :keymaps 'override
 ;;:keymaps '(
 ;;vterm-mode-map shell-mode-map sh-mode-map help-mode-map
 ;;helpful-mode-map dired-mode-map python-mode-map
 ;;emacs-lisp-mode-map sql-mode-map yaml-mode-map
 ;;org-mode-map csv-mode-map pubmed-mode-map
 ;;lisp-interaction-mode-map text-mode-map grep-mode-map
 ;;occur-mode-map json-mode-map jsonian-mode-map eww-mode-map
 ;;embark-collect-mode-map dockerfile-mode-map docker-compose-mode-map
 ;;docker-image-mode-map docker-container-mode-map eaf-mode-map
 ;;)
 "C-<tab>" 'tab-line-switch-to-next-tab
 "C-S-<tab>" 'tab-line-switch-to-prev-tab
 ;; works in modeline version
 "s-1" '(lambda () (interactive) (switch-to-buffer (nth 0 (z-project-mode-buffers))))
 "s-2" '(lambda () (interactive) (switch-to-buffer (nth 1 (z-project-mode-buffers))))
 "s-3" '(lambda () (interactive) (switch-to-buffer (nth 2 (z-project-mode-buffers))))
 "s-4" '(lambda () (interactive) (switch-to-buffer (nth 3 (z-project-mode-buffers))))
 "s-5" '(lambda () (interactive) (switch-to-buffer (nth 4 (z-project-mode-buffers))))
 "s-6" '(lambda () (interactive) (switch-to-buffer (nth 5 (z-project-mode-buffers))))
 "s-7" '(lambda () (interactive) (switch-to-buffer (nth 6 (z-project-mode-buffers))))
 "s-8" '(lambda () (interactive) (switch-to-buffer (nth 7 (z-project-mode-buffers))))
 "s-9" '(lambda () (interactive) (switch-to-buffer (nth 8 (z-project-mode-buffers))))
 )

(general-define-key
 :keymaps 'override
 ;; closes tab, doesn't kill buffer
 "s-w" 'z-tab-line-close-tab
 )

(provide 'z-tab-line)
;;; z-tab-line.el ends here
