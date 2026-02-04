;; -*- lexical-binding: t; -*-

(use-package color :ensure nil)
(set-face-attribute 'default nil :height 200)

(frame-parameter nil 'background-color)

;; Initialize brushup variables with safe defaults (updated properly after startup)
(defvar brushup-dark-p t)
(defvar brushup-fg "#ffffff")
(defvar brushup-bg "#000000")
(defvar brushup-gradient-step 7)
(defvar brushup-fg-1 "#e6e6e6")
(defvar brushup-fg-2 "#cccccc")
(defvar brushup-fg-3 "#b3b3b3")
(defvar brushup-fg-4 "#999999")
(defvar brushup-fg-5 "#808080")
(defvar brushup-fg-6 "#666666")
(defvar brushup-bg-1 "#1a1a1a")
(defvar brushup-bg-1_0 "#0d0d0d")
(defvar brushup-bg-2 "#333333")
(defvar brushup-bg-3 "#4d4d4d")
(defvar brushup-bg-4 "#666666")
(defvar brushup-bg-5 "#808080")
(defvar brushup-bg-6 "#999999")

(defun color-lighter-p (color1 color2)
  "Return t if COLOR1 is lighter than COLOR2."
  (let ((rgb1 (color-name-to-rgb color1))
        (rgb2 (color-name-to-rgb color2)))
    (when (and rgb1 rgb2)
      (> (nth 2 (apply 'color-rgb-to-hsl rgb1))
         (nth 2 (apply 'color-rgb-to-hsl rgb2))))))

(defun theme-light-p ()
  "Return t if the current theme is light, nil if dark.
This checks the background color of the default face."
  (let ((bg (face-background 'default)))
    (when bg  ; ensure we have a background color
      (color-lighter-p bg "gray50"))))

(defun theme-dark-p ()
  "Return t if the current theme is dark, nil if light."
  (not (theme-light-p)))

(defun brushup-init ()
  ;; Skip initialization in batch mode or when colors are unspecified
  (let* ((foreground (face-attribute 'default :foreground))
         (background (face-attribute 'default :background))
         (fg-valid (and foreground
                        (not (string-prefix-p "unspecified" (format "%s" foreground)))
                        (color-name-to-rgb foreground)))
         (bg-valid (and background
                        (not (string-prefix-p "unspecified" (format "%s" background)))
                        (color-name-to-rgb background))))
    (when (and fg-valid bg-valid)
      (setq brushup-dark-p (theme-dark-p)
            brushup-fg (if (equal foreground "black") "#000000" foreground)
            brushup-bg (if (equal background "white") "#ffffff" background)
            brushup-gradient-step 7)

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
         (color-lighten-name brushup-bg (* 6 (- brushup-gradient-step))))))))

;; Defer brushup-init until after startup for faster init
;; (brushup-init is called via z-brushup on theme load anyway)
(add-hook 'emacs-startup-hook #'brushup-init)

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
           :background (if brushup-dark-p
                           (color-lighten-name brushup-fg (- 60))
                         brushup-bg-3)
           :foreground 'unspecified)

          (setq ansi-term-color-vector [term term-color-black term-color-red
                                             term-color-green term-color-yellow
                                             term-color-blue term-color-magenta
                                             term-color-cyan term-color-white])

          (set-face-attribute
           'mode-line nil
           :background brushup-bg-1_0
           :foreground 'unspecified
           :box nil
           :underline nil
           :overline nil
           )

          ;; Emacs 29+ has mode-line-active face
          (when (facep 'mode-line-active)
            (set-face-attribute
             'mode-line-active nil
             :background brushup-bg-1_0
             :foreground 'unspecified
             :box nil
             :underline nil
             :overline nil
             ))

          (set-face-attribute
           'mode-line-inactive nil
           :foreground brushup-bg-6
           :background brushup-bg
           :underline nil
           :box nil
           )

          (set-face-attribute
           'header-line nil
           ;;:weight 'normal
           :background brushup-bg
           :underline nil
           :font "Terminus (TTF)"
           :box nil
           :inherit nil)

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
           'font-lock-comment-face nil
           :foreground
           (if brushup-dark-p
               (color-lighten-name brushup-bg 200)
             (color-lighten-name brushup-bg -50))
           :slant 'normal)
          (set-face-attribute
           'font-lock-doc-face nil
           :foreground
           (if brushup-dark-p
               (color-lighten-name brushup-bg 200)
             (color-lighten-name brushup-bg -50))
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

          ;; creates nice separator overlay between candidates
          (set-face-attribute 'minibuffer-prompt nil
          :foreground brushup-fg
          :background brushup-bg-1_0)

          (set-face-background 'fringe brushup-bg)

          (set-face-attribute
           'default nil
           :background 'unspecified)


          )
      (error (message "error in z-brushup"))
      )
    )
  )

(defun z-patch-face-fonts ()
  "I really don’t like bold text at ALL. Just disable them. This function is
        run after:
            a) startup is done i.e. as late as possible, and
            b) after a theme change.
        Hopefully by that time all faces are loaded."
  (interactive)
  (mapc (lambda (face)
          (set-face-attribute face nil
                              :slant 'normal
                              ;; NOTE need to do more work on the
                              ;; pipeline to remove this as weight is
                              ;; used in completion uis
                              ;;:weight 'normal
                              ))
        (face-list)))

(add-to-list 'brushup-styles '(z-patch-face-fonts))


(defun my-buffer-face-mode-pt-mono ()
  "Sets a fixed width (monospace) font in current buffer"
  (interactive)
  (setq buffer-face-mode-face '(:family "Terminus (TTF)"))
  (buffer-face-mode))

(defalias 'use-package-handler/:brushup 'use-package-handle-forms)
(defalias 'use-package-normalize/:brushup 'use-package-normalize-forms)
(add-to-list 'use-package-keywords :brushup t)

;; Run z-brushup after any theme is loaded to override theme's mode-line styling
(add-hook 'enable-theme-functions (lambda (_theme) (z-brushup)))

(provide 'bootstrap-brushup)


