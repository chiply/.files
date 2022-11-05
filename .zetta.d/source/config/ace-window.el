(use-package ace-window
  :demand t
  :brushup
  (add-to-list 'brushup-styles
               '(progn
                  (set-face-attribute 'aw-leading-char-face nil
                                      :background brushup-bg
                                      :foreground brushup-fg
                                      :height 4.0)
                  (set-face-attribute 'aw-mode-line-face nil
                                      :foreground brushup-fg
                                      :weight 'bold)))

  :config
  (setq aw-scope 'frame
        aw-dispatch-always t
        aw-char-position "left"
        aw-keys '(?a ?s ?d)
        aw-display-mode-overlay nil
        aw-background nil
        aw-minibuffer-flag t
        aw-ignore-current nil
        )
  (ace-window-display-mode)

  ;; helm buffer bring buffer name temporarily intto the headerline
  ;; TODO change this -- more modular, add to list
  (setq aw-ignored-buffers
        '(
          "*Calc Trail*" " *LV*"
          )
        )

  :general
  (
   :keymaps 'evil-insert-state-map
   (general-chord ",,") 'ace-window
   )
  (
   :states '(normal visual)
   :keymaps 'override
   :prefix ","
   "," 'ace-window
   )

  :hook (use-package--ace-window--post-config . z-brushup)
  )
