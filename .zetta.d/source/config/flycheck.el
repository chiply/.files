(use-package flycheck
  :brushup
  (add-to-list 'brushup-styles
               '(progn
                  (set-face-attribute 'flycheck-fringe-error nil
                                      :foreground brushup-fg
                                      :background brushup-bg-1)
                  (set-face-attribute 'flycheck-fringe-warning nil
                                      :foreground brushup-fg
                                      :background brushup-bg)
                  (set-face-attribute 'flycheck-fringe-info nil
                                      :foreground brushup-fg
                                      :background brushup-bg)
                  )
               )

  :display
  (z-side "^\\*Flycheck*" 'right 1)

  :hook (flycheck-error-list . (lambda () (text-scale-set -2)))
  )
