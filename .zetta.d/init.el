;; load init data
(add-to-list 'load-path "~/.files/.zetta.d/source/init-data")
(require 'init-data)

; bootstrap
(add-to-list 'load-path "~/.files/.zetta.d/source/bootstrap")
(require 'bootstrap)

;; install mandatory config files
(-each z-files-that-need-creating 'z-touch-maybe)

;; load user config files
(-map (lambda (pkg) (z-load-config-file pkg)) user-files)

(elpaca-process-queues)

;; load private.el
(load-file "~/.private.el")
