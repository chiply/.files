(use-package recursion-indicator
  :demand t
  :config
  (recursion-indicator-mode)

    :brushup
  (add-to-list 'brushup-styles
               '(progn
                  (set-face-attribute 'recursion-indicator-general nil
                                      :height 0.8
                                      )
                  (set-face-attribute 'recursion-indicator-minibuffer nil
                                      :height 0.8
                                      )
                  ))


  )
