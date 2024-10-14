(use-package project
  :ensure nil ;; builtin 
  :demand t
  :config
  (general-define-key
   :keymaps 'menu-project-keymap
   "w" 'menu-window
   "a" 'consult-ripgrep
   "p" 'project-switch-project
   "d" 'project-find-dir
   "f" 'project-find-file)
  (general-define-key
   :keymaps 'menu-window-keymap
   "p" 'menu-project)

  ;;:hydra
  ;;(defhydra+ hydra-window ()
  ;;("p" hydra-project/body :exit t)
  ;;)

  ;;(defhydra+ hydra-project ()
  ;;("w" hydra-window/body :exit t)
  ;;("A"   (lambda () (interactive)
  ;;(let ((current-prefix-arg '(4)))
  ;;(call-interactively 'consult-ripgrep)))
  ;;"rg - dir" :exit t :column "grep") 
  ;;("a"   consult-ripgrep "rg" :exit t :column "grep") 
  ;;("p"   project-switch-project "switch project" :exit t :column "Goto")
  ;;("d"   project-find-dir "dir")
  ;;("f"   project-find-file "file")
  ;;)
  )

;; TODO seems like this is under active development, just enabling,
;; but not using it yet
(use-package ede
  :ensure nil ;; builtin 
  :demand t
  :config
  (global-ede-mode))
