(use-package hercules
  :config

  (setq hercules-show-prefix t)

  (hercules-def
   :toggle-funs #'org-babel-mode
   :keymap 'org-babel-map
   :transient t
   :flatten t
   )

  (hercules-def
   :toggle-funs #'smerge-mode
   :keymap 'smerge-mode-map
   :transient t
   :flatten t
   )

  (hercules-def
   :toggle-funs #'hlt-highlight
   :keymap 'hlt-map
   :transient t
   :flatten t
   )

  ;; tweak binding to taste
  (define-key org-mode-map (kbd "C-c C-v") #'org-babel-mode)
  (define-key org-mode-map (kbd "C-c ^") #'smerge-mode)
  )
