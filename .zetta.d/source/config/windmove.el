(use-package windmove
  :config
  (defun z-split-window (how)
    (interactive)
    (cond
     ((string= how "v") (split-window-below) (windmove-down))
     ((string= how "V") (split-window-below))
     ((string= how "h") (split-window-right) (windmove-right))
     ((string= how "H") (split-window-right))
     )
    )

  :general
  (
   :states '(normal insert visual)
   :keymaps '(override treemacs-mode-map)
   "C-S-a" 'windmove-left
   "C-S-d" 'windmove-right
   "C-S-s" 'windmove-down
   "C-S-w" 'windmove-up
   )

  :hydra
  (defhydra+ hydra-window ()
    ("a" windmove-left)
    ("s" windmove-down)
    ("w" windmove-up)
    ("d" windmove-right)
    ("v" (z-split-window "v"))
    ("V" (z-split-window "V"))
    ("h" (z-split-window "h"))
    ("H" (z-split-window "H"))
    )
  )
