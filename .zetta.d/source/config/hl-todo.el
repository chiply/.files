(use-package hl-todo
  :config
  (setq hl-todo-keyword-faces
        '(("TODO"   . "#FF0000")
          ("FIXME"  . "#FF0000")
          ("GOTCHA" . "#FF4500")
          ("DEBUG"  . "#A020F0")
          ("STUB"   . "#1E90FF")
          ("LEFTOFF"   . "#0000FA")
          ("DONE"   . "#0000FA0F0000")
          ("NOTE"   . "#0000FA")
          ))
  :hook ((prog-mode markdown-mode) . hl-todo-mode))
