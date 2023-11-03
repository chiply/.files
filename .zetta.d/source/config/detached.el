
(use-package alert
  :config
  (setq alert-default-style 'osx-notifier)
  )




(use-package detached
  :init
  (setq detached-notification-function #'detached-extra-alert-notification)
  (detached-init)

  (defun z-detached-view-latest-session ()
    (interactive)
    (detached-view-session (nth 0 (detached-get-sessions)))
    )

  (defun z-detached-get-newest-buffer ()
    (nth 0 (last
            (cl-sort
             (-map
              (lambda (buf) (buffer-name buf))
              (-filter
               (lambda (buf) (string-match-p "\\*Detached Shell Command*" (buffer-name buf)))
               (buffer-list)))
             'string-lessp
             ))))

  :display
  (z-side "^\\*detached*" 'top 1)
  (z-side "detached-tail-mode" 'top 1)
  (z-side "detached-log-mode" 'top 1)
  (z-side "detached-compilation-mode" 'top 1)

  :general
  (
   :keymaps 'override
   "<s-return>" 'z-detached-view-latest-session
   )

  :hook ((detached-log-mode
          detached-tail-mode
          detached-compilation-mode) .
          (lambda () (progn (z-highlight-phrases)
                            (toggle-truncate-lines)
                            (text-scale-set -2)
                            )))
  )
