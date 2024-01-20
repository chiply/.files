(use-package gptel
  :general
  (:keymaps 'override
            :states '(normal insert visual)
            "s-p" 'gptel-send
            "s-P" 'gptel))
