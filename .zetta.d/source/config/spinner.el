(use-package spinner
  :after (compile)
  :config
  ;; Starting
  (add-hook 'compilation-start-hook (lambda (_) (spinner-start)))

  ;; Stop
  (defun z-compile-spin-stop (buffer result)
    "Executes spinner-stop strategy depending on compilation exit status."
    (cond ((string-match "^finished" result) (spinner-stop))
          ((string-match "^exited abnormally" result) (spinner-stop))))

  (add-to-list 'compilation-finish-functions 'z-compile-spin-stop))
