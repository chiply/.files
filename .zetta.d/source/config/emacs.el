(use-package emacs
  :ensure nil
  :demand t
  :config
  (setq ring-bell-function #'ignore)
  (general-define-key
   :keymaps 'override
   "M-q" 'fill-paragraph))
