
(defvar bootstrap-version)

(setq straight-base-dir "~/.files/.zetta.d/source")

(let ((bootstrap-file
       (expand-file-name
        "source/straight/repos/straight.el/bootstrap.el"
        user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; install use-package
(setq straight-base-dir "~/.files/.zetta.d/source")
(setq straight-build-dir "build")
(straight-use-package 'use-package)
(require 'use-package)

;; make use package leverage straight for installing packages
(setq straight-use-package-by-default t)

(setq use-package-inject-hooks t)

(defun use-package-handle-forms (name _keyword arg rest state)
  (let* ((body (use-package-process-keywords name rest state))
         (name-symbol (use-package-as-symbol name)))
    (use-package-concat
     (when use-package-compute-statistics
       `((use-package-statistics-gather :config ',name nil)))
     (if (and (or (null arg) (equal arg '(t))) (not use-package-inject-hooks))
         body
       (use-package-with-elapsed-timer
           (format "Configuring package %s" name-symbol)
         (funcall use-package--hush-function :config
                  (use-package-concat
                   (use-package-hook-injector
                    (symbol-name name-symbol) :config arg)
                   body
                   (list t)))))
     (when use-package-compute-statistics
       `((use-package-statistics-gather :config ',name t))))))


(provide 'bootstrap-config)
