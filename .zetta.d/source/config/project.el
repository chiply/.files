(use-package project
  :straight (:type built-in) 
  :demand t
  :hydra
  (defhydra+ hydra-window ()
    ("p" hydra-project/body :exit t)
    )

  (defhydra+ hydra-project ()
    ("w" hydra-window/body :exit t)
    ("A"   (lambda () (interactive)
             (let ((current-prefix-arg '(4)))
               (call-interactively 'consult-ripgrep)))
     "rg - dir" :exit t :column "grep") 
    ("a"   consult-ripgrep "rg" :exit t :column "grep") 
    ("p"   project-switch-project "switch project" :exit t :column "Goto")
    ("d"   project-find-dir "dir")
    ("f"   project-find-file "file")))

;; TODO seems like this is under active development, just enabling,
;; but not using it yet
(use-package ede
  :straight (:type built-in) 
  :demand t
  :config
  (global-ede-mode))
