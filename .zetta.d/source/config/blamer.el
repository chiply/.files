(use-package blamer
  :ensure t
  :custom
  (blamer-idle-time 0.3) ;; match lsp sidlein
  (blamer-min-offset 10)
  (blamer-max-commit-message-length 50)
  :custom-face
  (blamer-face ((t :foreground "#7a88cf"
                    :background nil
                    :height 140
                    :italic t)))
  :config
  ;;(global-blamer-mode 1)
)
