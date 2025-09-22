(use-package buffer-terminator
  :ensure t
  :custom
  (buffer-terminator-verbose nil)

  ;; Set the inactivity timeout (in seconds) after which buffers are considered
  ;; inactive (default is 30 minutes):
  (buffer-terminator-inactivity-timeout (* 2 60)) ; 2 minutes

  ;; Define how frequently the cleanup process should run (default is every 10
  ;; minutes):
  (buffer-terminator-interval (* 2 60)) ; 2 minutes

  :config
  (buffer-terminator-mode 1))
