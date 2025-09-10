(use-package windmove
  :ensure nil
  :commands (z-split-window-v
             z-split-window-V
             z-split-window-h
             z-split-window-H
             windmove-left
             windmove-right
             windmove-down
             windmove-up)
  :config
  (defun z-split-window (how)
    (interactive)
    (cond
     ((string= how "v") (split-window-below) (windmove-down))
     ((string= how "V") (split-window-below))
     ((string= how "h") (split-window-right) (windmove-right))
     ((string= how "H") (split-window-right))))

  (defun z-split-window-v () (interactive) (z-split-window "v"))
  (defun z-split-window-h () (interactive) (z-split-window "h"))
  (defun z-split-window-V () (interactive) (z-split-window "V"))
  (defun z-split-window-H () (interactive) (z-split-window "H"))

  :general
  (
   :keymaps '(override treemacs-mode-map)
   "C-S-a" 'windmove-left
   "C-S-d" 'windmove-right
   "C-S-s" 'windmove-down
   "C-S-w" 'windmove-up
   )
  (
   :keymaps 'menu-window-map
   "v" (** z-split-window-v)
   "V" (** z-split-window-V)
   "h" (** z-split-window-h)
   "H" (** z-split-window-H)
   )
  )
