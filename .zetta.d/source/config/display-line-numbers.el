(use-package display-line-numbers
  :straight nil
  :demand t

  :init 
  (setq-default
   display-line-numbers-type 'visual
   display-line-numbers-current-absolute t
   display-line-numbers-width-start 5 display-line-numbers-widen t
   display-line-numbers 'relative display-line-numbers-major-tick 20
   display-line-numbers-minor-tick 10)

  :config
  (global-display-line-numbers-mode)

  :brushup
  (add-to-list 'brushup-styles
               '(progn
                  (set-face-attribute 'line-number nil
                                      :foreground brushup-fg
                                      :background brushup-bg)
                  (set-face-attribute 'line-number-current-line nil
                                      :inherit 'line-number
                                      :foreground brushup-fg
                                      :background brushup-bg
                                      :weight 'bold)
                  (set-face-attribute 'line-number-major-tick nil
                                      :inherit 'line-number
                                      :foreground brushup-fg
                                      :background brushup-bg-1)
                  (set-face-attribute 'line-number-minor-tick nil
                                      :inherit 'line-number
                                      :foreground brushup-fg
                                      :background brushup-bg-1_0)))

  :hook (((vterm-mode) . (lambda () (display-line-numbers-mode -1)))
         ((pdf-view-mode) . (lambda () (display-line-numbers-mode -1)))))
