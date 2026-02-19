(use-package ef-themes
  ;; set ef theme to ef-light
  :config
  (load-theme 'ef-light t)
  ;; ensure brushup styling is applied after theme loads
  (when (fboundp 'zetta-brushup)
    (zetta-brushup)))
  
