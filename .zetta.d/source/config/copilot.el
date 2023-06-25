(use-package copilot
  :straight (:host github :repo "zerolfx/copilot.el" :files ("dist" "*.el"))

  )


(general-define-key
 :keymaps '(copilot-completion-map)
 "C-<return>" 'copilot-accept-completion
 "C-f" 'copilot-accept-completion-by-word
 "C-S-f" 'copilot-accept-completion-by-line
 "C-S-M-f" 'copilot-accept-completion-by-paragraph
 "C-n" 'copilot-next-completion
 "C-p" 'copilot-previous-completion
 )
