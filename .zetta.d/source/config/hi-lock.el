(use-package hi-lock
  :straight (:type built-in)
  :demand t
  :config
  ;; prevents issues with precedence over hl-line
  (setq hi-lock-use-overlays nil)
  )

