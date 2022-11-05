(use-package bookmark+
  :config
  
  
  :brushup
  (add-to-list 'brushup-styles
               '(progn
                  (set-face-attribute 'bmkp-light-mark nil
                                      :inherit nil
                                      :foreground brushup-fg-1
                                      :background brushup-bg
                                      )
                  (set-face-attribute 'bmkp-light-fringe-non-autonamed nil
                                      :inherit nil
                                      :foreground brushup-fg-1
                                      :background brushup-bg-1_0
                                      )
                  ))

  :hook ((org-mode python-mode emacs-lisp-mode) . (lambda ()
                                                    (call-interactively 'bmkp-light-bookmarks)))
  )
