(use-package mono-complete
  :config
  (setq mono-complete-fallback-command 'tab-to-tab-stop)
  (define-key mono-complete-mode-map (kbd "C-S-f") 'mono-complete-expand-or-fallback)

  :commands (mono-complete-mode)
  :hook ((prog-mode) . mono-complete-mode))
