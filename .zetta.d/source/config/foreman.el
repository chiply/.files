(use-package foreman
  :straight nil
  :load-path "~/.files/.zetta.d/source/zettapkg/foreman"
  :demand t

  :display
  (z-side "^\\*4t0*" 'top)
  (z-side "^\\*4t1*" 'top 1)
  (z-side "^\\*4b0*" 'bottom)
  (z-side "^\\*4r0*" 'right)
  )
