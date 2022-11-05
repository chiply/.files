(use-package hercules
  :config
  (hercules-def
   ;; read further to see why this works
   :toggle-funs #'org-babel-mode
   :keymap 'org-babel-map
   :transient t
   )
  
  ;; tweak binding to taste
  (define-key org-mode-map (kbd "C-c C-v") #'org-babel-mode)


  )
