(use-package git-gutter
  :init
  (global-git-gutter-mode)

  :config
  (setq git-gutter:window-width 2)
  (setq git-gutter:update-interval 2)

  ;; add indicator to margin showing the current line number

  ;;:brushup
  ;;(add-to-list 'brushup-styles
               ;;'(progn
                  ;;(setq brushup-git-gutter-foreground brushup-bg-5
                        ;;brushup-git-gutter-background brushup-bg)
                  ;;(set-face-attribute 'git-gutter:added nil
                                      ;;:foreground brushup-git-gutter-foreground
                                      ;;:background (modus-themes-get-color-value 'bg-green-nuanced))
                  ;;(set-face-attribute 'git-gutter:deleted nil
                                      ;;:foreground brushup-git-gutter-foreground
                                      ;;:background (modus-themes-get-color-value 'bg-red-nuanced))
                  ;;(set-face-attribute 'git-gutter:modified nil
                                      ;;:foreground brushup-git-gutter-foreground
                                      ;;:background (modus-themes-get-color-value 'bg-yellow-nuanced))
                  ;;(set-face-attribute 'git-gutter:separator nil
                                      ;;:foreground brushup-git-gutter-foreground
                                      ;;:background brushup-git-gutter-background)))

  (general-define-key :keymaps 'menu-project-keymap
                      "g" 'git-gutter
                      "j" 'git-gutter:next-hunk
                      "k" 'git-gutter:previous-hunk)

  ;;:hydra
  ;;(defhydra+ hydra-project ()
    ;;("g" git-gutter "Gutter" :column "Git Gutter")
    ;;("j" git-gutter:next-hunk)
    ;;("k" git-gutter:previous-hunk))

  :hook (use-package--git-gutter--post-config . z-brushup)
  )
