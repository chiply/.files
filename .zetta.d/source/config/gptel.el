(use-package gptel
  :demand t
  :general
  (
   :keymaps 'override
   "s-p" 'gptel-send
   "s-P" 'gptel)
  )

(use-package gptel-quick
  :ensure (gptel-quick :type git :host github :repo "karthink/gptel-quick")
  :demand t
  :after gptel
  :config
  (keymap-set embark-general-map "?" #'gptel-quick))


(use-package corsair
  :ensure (corsair :type git :host github
                   :repo "rob137/Corsair"
                   :files ("corsair.el"))
  :demand t
  :after gptel ; Ensure gptel is loaded before corsair
  )

