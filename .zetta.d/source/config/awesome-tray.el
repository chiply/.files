(use-package celestial-mode-line)
(use-package awesome-tray
  :ensure (awesome-tray :type git :host github :repo "manateelazycat/awesome-tray")
  :config
  (setq awesome-tray-second-line t)
  (setq awesome-tray-hide-mode-line nil)
  ;; only gets so instantaneous, remove things that benefit from
  ;; instant feedback (like location, na)
  (setq awesome-tray-refresh-idle-delay 0.01)
  (setq awesome-tray-update-interval 1)
  (setq awesome-tray-belong-update-duration 0.1)
  (setq awesome-tray-position 'center)
  (setq awesome-tray-active-modules
        ;; NOTE update
        '("last-command" "belong" "hostname" "file-path" "mode-name"
          "battery" "date" "celestial" "pdf-view-page" "input-method"
          "buffer-read-only"))
  (awesome-tray-mode 1)
  )

