(use-package default-text-scale
  :after face-remap
  :hydra
  (defhydra+ hydra-window ()
    ("C-+" default-text-scale-increase)
    ("C-_" default-text-scale-decrease)
    )
  )
