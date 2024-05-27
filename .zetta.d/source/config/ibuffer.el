(use-package ibuffer
  :straight nil
  :demand t

  :init
  (defun z-soda-create-and-display-ibuffer (&optional buf-or-mode-name)
    (interactive)
    (ibuffer nil buf-or-mode-name nil []))

  :display
  ;;(z-side "^\\*Ibuffer*" 'left 2 0.10)
  

  :hydra
  (defhydra+ hydra-run ()
    ("b" (lambda ()
           (interactive)
           (z-soda-drink (quote z-soda-create-and-display-ibuffer) "*Ibuffer*")
           ) "Ibuffer" :column "Drink")
    ("B" (lambda () (interactive) (z-soda-cap "*Ibuffer*")) "Ibuffer" :column "Cap")
    )

  :hook (
         (ibuffer-mode . (lambda () (visual-line-mode -1)))
         (ibuffer-mode . (lambda () (text-scale-set -2)))
         (ibuffer-mode . (lambda () (ibuffer-auto-mode 1)))
         )
  )
