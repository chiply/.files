(use-package hl-line
  :straight nil
  :init
  (global-hl-line-mode -1)
  (make-variable-buffer-local 'global-hl-line-mode)
  (setq hl-line-overlay-priority -5000)

  ;;:brushup
  ;;(add-to-list 'brushup-styles
               ;;'(progn
                  ;;(set-face-attribute 'hl-line nil
                                      ;;:background (if brushup-dark-p
                                                      ;;(color-lighten-name brushup-bg 2)
                                                    ;;(color-lighten-name brushup-bg -4)
                                                    ;;)
                                      ;;:inherit nil
                                      ;;:extend t
                                      ;;)
                  ;;))

  ;;:hook (use-package--hl-line--post-config . z-brushup)
  )


