;; (use-package compile
;;   :straight (:type built-in)
;;   :config

;;   (defun emacs-compile-plus/buffer-name(dir command)
;;     "Return a function suitable for `compilation-buffer-name-function'.
;; The returned function concatenates the DIR and COMMAND."
;;     `(lambda (majormode)
;;        (concat "*" ,(let ((path (abbreviate-file-name default-directory)))
;;                       (if (> (length path) 30)
;;                           (z-minify-path default-directory)
;;                         path
;;                         )
;;                       )
;;                " - " ,command "*")))


;;   (defun emacs-compile-plus/compile(dir command)
;;     "Compile by explicitly giving the DIR to compile the given COMMAND in and."
;;     (interactive (list
;;                   ;; todo add arg
;;                   (if nil
;;                       (read-directory-name "Directory to compile in: ")
;;                     default-directory
;;                     )
;;                   ;; Rest is copied from `compile'.
;;                   (let ((command (eval compile-command)))
;;                     (if (or compilation-read-command current-prefix-arg)
;;                         (compilation-read-command command)))))
;;     (let ((default-directory dir)
;;           (compilation-buffer-name-function (emacs-compile-plus/buffer-name dir command)))
;;       (message "CMD:: %s" command)
;;       (message "DIR:: %s" dir)
;;       ;; Rest is copied from `compile'.
;;       (message "%s" (funcall compilation-buffer-name-function "my cmd"))
;;       (unless (equal command (eval compile-command))
;;         (setq compile-command command))
;;       (save-some-buffers (not compilation-ask-about-save)
;;                          compilation-save-buffers-predicate)
;;       (setq-default compilation-directory default-directory)
;;       (compilation-start command nil)))

;;   (advice-add #'compile :override #'emacs-compile-plus/compile)

;;   )
