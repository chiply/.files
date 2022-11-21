(use-package ob-mermaid
  :config
  (setq ob-mermaid-cli-path (s-trim (shell-command-to-string "which mmdc")))
  )
