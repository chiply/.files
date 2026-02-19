(use-package ace-window
  :commands (ace-window ace-select-window ace-delete-window ace-swap-window)
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
   :keymaps 'launch-map
   "," 'ace-window
   )

  :hook (use-package--ace-window--post-config . zetta-brushup)
  )
