(use-package detached
  :config
  ;; this avoids a cryptic error.  For whatever reason I'm able to
  ;; proceed with using detached despite ignoring the error in
  ;; detached-init
  (condition-case nil (detached-init) (error nil))
  (add-hook 'detached-log-mode-hook
            '(lambda ()
               (progn
                 (compilation-minor-mode t)
                 (z-highlight-phrases)
                 )))
  ;;(detached-init)
  (defun z-detached-alert-notification (session) (ignore))
  :custom ((detached-show-output-on-attach t)
           (detached-terminal-data-command system-type)
           (detached-notification-function #'z-detached-alert-notification))

  :general
  (
   :keymaps '(detached-log-mode-map)
   "S-<tab>" 'compilation-previous-error
   )
  )


