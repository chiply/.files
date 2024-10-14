;; install use-package
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

(provide 'bootstrap-use-package)
