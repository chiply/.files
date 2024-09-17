(use-package gptel
  :demand t
  :config
  (use-package gptel-quick
    :straight (gptel-quick :type git :host github :repo "karthink/gptel-quick")
    :demand t
    :config
    (keymap-set embark-general-map "?" #'gptel-quick))

  :general
  (
   :keymaps 'override
   "s-p" 'gptel-send
   "s-P" 'gptel)
  )


