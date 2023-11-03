(use-package hi-lock
  :straight (:type built-in)
  :config
  ;; prevents issues with precedence over hl-line
  (setq hi-lock-use-overlays t)
  )

