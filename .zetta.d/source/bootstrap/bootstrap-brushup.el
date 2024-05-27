(use-package color)

(defun brushup-init ()
  (setq brushup-dark-p (equal
                        "dark"
                        (symbol-name
                         (alist-get 'background-mode
                                    (frame-parameters))))
        brushup-fg (let ((foreground (face-attribute 'default :foreground)))
                     (if (equal foreground "black")
                         (message "#000000")
                       (message foreground)))
        brushup-bg (let ((background (face-attribute 'default :background)))
                     (if (equal background "white")
                         (message "#ffffff")
                       (message background)))
        brushup-gradient-step 7
        )

  (setq
   brushup-fg-1
   (if brushup-dark-p
       (color-lighten-name brushup-fg (- brushup-gradient-step))
     (color-lighten-name brushup-fg brushup-gradient-step))
   brushup-fg-2
   (if brushup-dark-p
       (color-lighten-name brushup-fg (* 2 (- brushup-gradient-step)))
     (color-lighten-name brushup-fg (* 2 brushup-gradient-step )))
   brushup-fg-3
   (if brushup-dark-p
       (color-lighten-name brushup-fg (* 3 (- brushup-gradient-step)))
     (color-lighten-name brushup-fg (* 3 brushup-gradient-step )))
   brushup-fg-4
   (if brushup-dark-p
       (color-lighten-name brushup-fg (* 4 (- brushup-gradient-step)))
     (color-lighten-name brushup-fg (* 4 brushup-gradient-step )))
   brushup-fg-5
   (if brushup-dark-p
       (color-lighten-name brushup-fg (* 5 (- brushup-gradient-step)))
     (color-lighten-name brushup-fg (* 5 brushup-gradient-step )))
   brushup-fg-6
   (if brushup-dark-p
       (color-lighten-name brushup-fg (* 6 (- brushup-gradient-step)))
     (color-lighten-name brushup-fg (* 6 brushup-gradient-step )))
   brushup-bg-1
   (if brushup-dark-p
       (color-lighten-name brushup-bg brushup-gradient-step)
     (color-lighten-name brushup-bg (- brushup-gradient-step)))
   brushup-bg-1_0 (color-lighten-name brushup-bg (- 3)) ;; for solair
   brushup-bg-2
   (if brushup-dark-p
       (color-lighten-name brushup-bg (* 2 brushup-gradient-step))
     (color-lighten-name brushup-bg (* 2 (- brushup-gradient-step))))
   brushup-bg-3
   (if brushup-dark-p
       (color-lighten-name brushup-bg (* 3 brushup-gradient-step ))
     (color-lighten-name brushup-bg (* 3 (- brushup-gradient-step))))
   brushup-bg-4
   (if brushup-dark-p
       (color-lighten-name brushup-bg (* 4 brushup-gradient-step))
     (color-lighten-name brushup-bg (* 4 (- brushup-gradient-step))))
   brushup-bg-5
   (if brushup-dark-p
       (color-lighten-name brushup-bg (* 5 brushup-gradient-step))
     (color-lighten-name brushup-bg (* 5 (- brushup-gradient-step))))
   brushup-bg-6
   (if brushup-dark-p
       (color-lighten-name brushup-bg (* 6 brushup-gradient-step ))
     (color-lighten-name brushup-bg (* 6 (- brushup-gradient-step)))))
  )



(setq brushup-styles '())
(add-to-list 'brushup-styles '(brushup-init))

(defun brushup-eval (function)
  (condition-case err
      (eval function)
    (error (message (concat
                     "error in brushup-eval"
                     (error-message-string err))))))


(defun brushup ()
  (interactive)
  ;; call to init; sets the brushup-fg/bg
  (-map (lambda (function) (brushup-eval function)) brushup-styles))



(defun z-brushup ()
  "Mostly handles themeing, but also takes care of other things that
seem to require loading after the client starts up"
  (interactive) 
  (when window-system
    (brushup)

    ;; default
    (condition-case nil
        (progn
          (set-face-attribute
           'region nil
           :background
           (if brushup-dark-p (color-lighten-name brushup-fg (- 60)) brushup-bg-2)
           :foreground 'unspecified)


          (setq ansi-term-color-vector [term term-color-black term-color-red
                                             term-color-green term-color-yellow
                                             term-color-blue term-color-magenta
                                             term-color-cyan term-color-white])

          (set-face-attribute
           'mode-line nil
           :background brushup-bg
           ;;:overline nil
           ;;:underline nil
           :font "Pt Mono"
           ;;:box t
           )

          (set-face-attribute
           'mode-line-inactive nil
           ;;:overline nil
           ;;:underline nil
           :font "Pt Mono"
           ;;:box t
           )

          (set-face-attribute
           'header-line nil
           ;;:height 'unspecified
           ;;:weight 'normal
           :font "PT Mono 11"
           )

          (set-face-attribute
           'sh-heredoc nil
           :foreground brushup-fg
           :weight 'normal)

          (set-face-attribute
           'button nil
           :foreground brushup-fg
           :background brushup-bg
           :box nil
           :underline t)

          (set-face-attribute
           'emoji nil
           :font "Apple Color Emoji 11"
           :height 0.1
           :inherit nil
           )


          (set-face-attribute
           'font-lock-comment-face nil
           :foreground
           (if brushup-dark-p
               (color-lighten-name brushup-bg 25)
             (color-lighten-name brushup-bg -25))
           :slant 'normal)

          (set-face-attribute
           'font-lock-string-face nil
           :slant 'normal)

          (set-face-attribute
           'font-lock-doc-face nil
           :foreground
           (if brushup-dark-p
               (color-lighten-name brushup-bg 30)
             (color-lighten-name brushup-bg -30)
             ))

          ;;(set-face-attribute 'minibuffer-prompt nil
          ;;:foreground brushup-fg
          ;;:background brushup-bg-1)

          ;; set the background of the fringe to black
          (set-face-background 'fringe brushup-bg-1_0)

          (set-face-attribute
           'default nil
           :background nil)


          )
      (error (message "error in z-brushup"))
      )
    )
  )


(defalias 'use-package-handler/:brushup 'use-package-handle-forms)
(defalias 'use-package-normalize/:brushup 'use-package-normalize-forms)

(add-to-list 'use-package-keywords :brushup t)

(defun my-buffer-face-mode-pt-mono ()
  "Sets a fixed width (monospace) font in current buffer"
  (interactive)
  (setq buffer-face-mode-face '(:family "PT Mono"))
  (buffer-face-mode))

;; (defun my-buffer-face-mode-pt-mono-p85 ()
;;   "Sets a fixed width (monospace) font in current buffer"
;;   (interactive)
;;   (setq buffer-face-mode-face '(:family "PT Mono" :height 0.87))
;;   (buffer-face-mode))


(provide 'bootstrap-brushup)


