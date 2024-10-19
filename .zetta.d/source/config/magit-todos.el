;; note this doesn't work
;; TODO 
 (use-package hl-todo
   :config
   (setq hl-todo-keyword-faces
       '(("TODO"   . "#FF0000")
         ("FIXME"  . "#FF0000")
         ("DEBUG"  . "#A020F0")
         ("GOTCHA" . "#FF4500")
         ("STUB"   . "#1E90FF")))
   :hook ((prog-mode markdown-mode) . hl-todo-mode))

;; (use-package magit-todos
;;   :after magit
;;   ;TODO: foobarbaz
;;   :config (magit-todos-mode 1))
