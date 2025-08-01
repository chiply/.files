(use-package face-remap
  :ensure nil
  :config
  (setq text-scale-mode-step 1.2)

  (defun z-big-zoom-in ()
    (interactive)
    (if (< text-scale-mode-amount 4)
        (text-scale-set 4)
      (text-scale-set 0)))

  (defun z-big-zoom-out ()
    (interactive)
    (if (> text-scale-mode-amount -4)
        (text-scale-set -4)
      (text-scale-set 0)))

  :general
  (
   :keymaps 'menu-window-map
   "=" (** text-scale-increase)
   "-" (** text-scale-decrease)
   "+" (** z-big-zoom-in)
   "_" (** z-big-zoom-out)
   )
  )
