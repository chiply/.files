(use-package compile
  :straight (:type built-in)
  :config (setq compilation-scroll-output nil)
  :general (:keymaps '(override) "s-r" 'recompile)

  )


