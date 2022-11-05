(use-package dimmer
  :config
  (dimmer-configure-helm)
  (dimmer-configure-hydra)
  (dimmer-configure-which-key)

  (setq dimmer-watch-frame-focus-events nil
        dimmer-fraction 0.4
        dimmer-buffer-exclusion-regexps
        '(".*Minibuf.*" ".*which-key.*" ".*NeoTree.*" ".*Warnings.*"
          ".*LV.*" ".*Ivy.*" ".*Hydra.*" ".*Ilist.*"))

  (push (lambda (buf) (string= (buffer-name buf) "file-peak"))
        dimmer-buffer-exclusion-predicates)

  (dimmer-mode t)

  :hydra
  (defhydra+ hydra-window ()
    ;; awkward, but clearing space
    ("C-S-F D" dimmer-mode)
    )
  )
