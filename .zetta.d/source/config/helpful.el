(use-package helpful
  :demand t
  :init

  (defun z-helpful-at-point ()
    (interactive)
    (let ((buf (current-buffer)))
      (helpful-at-point)
      (select-window (get-buffer-window buf))
      )
    )

  (setq helpful-switch-buffer-function 'display-buffer)

  (general-define-key
   :keymaps 'menu-run-keymap
   "H" (lambda () (interactive) (z-soda-cap "[H|h]elp*" 1)))

  :hydra

  (defhydra+ hydra-helpful ()
    ("c" helpful-command "Command" :column "Helpful")
    ("f" helpful-function "Function" :exit t)
    ("v" helpful-variable "Variable" :exit t)
    ("h" z-jump-to-doc "At point" :exit t)
    ("k" helpful-key "Key sequence" :exit t)
    ("a" helm-apropos "Apropos" :column "Helm apropos" :exit t)
    ("A" apropos "Apropos" :exit t)
    ("m" z-describe-mode "Mode" :column "Mode" :exit t)
    ("i" info "Info" :column "Manual" :exit t)
    )

  ;;(defhydra+ hydra-run ()
    ;;("H" (lambda () (interactive) (z-soda-cap "[H|h]elp*" 1)) "Help")
    ;;)

  :general
  (
   :keymaps 'launch-map
   "h" 'hydra-helpful/body
   )

  :hook (helpful-mode . (lambda () (text-scale-set -2)))
  )


