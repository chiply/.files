(use-package yascroll
  :config
  (global-yascroll-bar-mode)
  :brushup
  (add-to-list 'brushup-styles
               '(progn
                  (set-face-attribute 'yascroll:thumb-fringe nil
                                      :foreground brushup-bg-1
                                      :background brushup-bg-1
                                      )
                  (set-face-attribute 'yascroll:thumb-text-area nil
                                      :foreground brushup-bg-1
                                      :background brushup-bg-1
                                      )

                  )
               )


  )
