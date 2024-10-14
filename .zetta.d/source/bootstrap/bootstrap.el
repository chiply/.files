;; order is specified by require statements to laod the packages in
;; lieu of use-package because it is not declared yet
;;(require 'bootstrap-config) ;; straight, use-package
;;(require 'bootstrap-use-package)

(require 'bootstrap-elpaca) ;; straight, use-package

;; TODO start using use package from here on?
(require 'bootstrap-utils)
(require 'bootstrap-keys)
(require 'bootstrap-brushup)
(require 'bootstrap-menu)
(require 'bootstrap-hydra)
(require 'bootstrap-display)
(require 'bootstrap-evil)
(require 'bootstrap-org)
(require 'bootstrap-zettafn)

(provide 'bootstrap)
