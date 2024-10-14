(use-package hi-lock
  :ensure nil ;; builtin
  :demand t
  :config
  ;; prevents issues with precedence over hl-line
  (setq hi-lock-use-overlays nil)
  )

