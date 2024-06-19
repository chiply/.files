(use-package copilot
  :straight (:host github :repo "zerolfx/copilot.el" :files ("dist" "*.el"))
  :config
  (add-hook 'prog-mode-hook 'copilot-mode)
  (add-hook 'mardown-mode-hook 'copilot-mode)
  (add-hook 'org-mode-hook 'copilot-mode)
  (add-hook 'sql-mode-hook 'copilot-mode)
  (add-hook 'mermaid-mode-hook 'copilot-mode)
  (add-hook 'emacs-lisp-mode 'copilot-mode)
  (add-hook 'lisp-interaction-mode 'copilot-mode)
  :general (:keymaps '(copilot-completion-map)
                     "C-<return>" 'copilot-accept-completion
                     "C-S-f" 'copilot-accept-completion-by-word
                     "C-S-M-f" 'copilot-accept-completion-by-line
                     ;;"C-S-M-f" 'copilot-accept-completion-by-paragraph
                     "C-n" 'copilot-next-completion
                     "C-p" 'copilot-previous-completion))



