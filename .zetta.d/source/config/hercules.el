(use-package hercules
  :config
  (hercules-def
   :toggle-funs #'org-babel-mode
   :keymap 'org-babel-map
   :transient t
   )

  (hercules-def
   :toggle-funs #'smerge-mode
   :keymap 'smerge-mode-map
   :transient t
   )

  
  ;; tweak binding to taste
  (define-key org-mode-map (kbd "C-c C-v") #'org-babel-mode)
  (define-key org-mode-map (kbd "C-c ^") #'smerge-mode)



  )
