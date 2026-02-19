(use-package ibuffer
  :ensure nil
  :commands ibuffer

  :init
  (defun z-soda-create-and-display-ibuffer (&optional buf-or-mode-name)
    (interactive)
    (ibuffer nil buf-or-mode-name nil []))

  (defun z-soda-drink-ibuffer ()
    (interactive)
    (z-soda-drink (quote z-soda-create-and-display-ibuffer) "*Ibuffer*"))

  (defun z-soda-cap-ibuffer ()
    (interactive)
    (z-soda-cap "*Ibuffer*"))

  (general-define-key
   :keymaps 'menu-run-map
   "b" (** z-soda-drink-ibuffer)
   "B" (** z-soda-cap-ibuffer))

  :hook (
         (ibuffer-mode . (lambda () (visual-line-mode -1)))
         (ibuffer-mode . (lambda () (text-scale-set -2)))
         (ibuffer-mode . (lambda () (ibuffer-auto-mode 1)))
         )
  )
