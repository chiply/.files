(use-package copilot
  :straight (:host github :repo "zerolfx/copilot.el" :files ("dist" "*.el"))

  :brushup
  (add-to-list 'brushup-styles
               '(progn
                  (set-face-attribute 'copilot-overlay-face nil
                                      :foreground (modus-themes-get-color-value 'green-intense)
                                      :background brushup-bg))))

(general-define-key
 :keymaps '(copilot-completion-map)
 "C-<return>" 'copilot-accept-completion
 "C-f" 'copilot-accept-completion-by-word
 "C-S-f" 'copilot-accept-completion-by-line
 "C-S-M-f" 'copilot-accept-completion-by-paragraph
 "C-n" 'copilot-next-completion
 "C-p" 'copilot-previous-completion
 )

