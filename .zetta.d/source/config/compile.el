(use-package compile
  :ensure nil ;; builtin
  :config (setq compilation-scroll-output nil)
  :general (:keymaps '(override) "s-r" 'recompile)

  )


