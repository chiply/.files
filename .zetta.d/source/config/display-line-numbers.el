(use-package display-line-numbers
  :straight nil
  :demand t

  :init 
  (setq-default display-line-numbers-type 'visual
                display-line-numbers-current-absolute t
                ;;display-line-numbers-width 5
                display-line-numbers-width-start 5
                display-line-numbers-widen t
                display-line-numbers 'relative
                display-line-numbers-major-tick 20
                display-line-numbers-minor-tick 10
                ;;display-grow-only t
                )

  :config
  (global-display-line-numbers-mode)

  :brushup
  (add-to-list 'brushup-styles
               '(progn
                  (set-face-attribute 'line-number nil
                                      :foreground brushup-bg-3
                                      :background brushup-bg
                                      :inherit nil
                                      ;; NEED FLOATING POINT NUMBER, this is
                                      ;; super critical, otherwise we get the
                                      ;; weird alignment isue
                                      ;;:height nil
                                      ;:height 1.0
                                      )
                  (set-face-attribute 'line-number-current-line nil
                                      :foreground brushup-fg
                                      :background brushup-bg-1_0
                                      :inherit nil
                                      ;;:height nil
                                      ;:height 1.0
                                      )
                  (set-face-attribute 'line-number-major-tick nil
                                      :foreground brushup-bg-6
                                      :background brushup-bg
                                      :inherit nil
                                      ;;:height nil
                                      ;:height 1.0
                                      )
                  (set-face-attribute 'line-number-minor-tick nil
                                      :foreground brushup-bg-4
                                      :background brushup-bg
                                      :inherit nil
                                      ;;:height nil
                                      ;:height 1.0
                                      )
                  )
               )

  :hook (vterm-mode . (lambda () (display-line-numbers-mode -1)))
  


  )
