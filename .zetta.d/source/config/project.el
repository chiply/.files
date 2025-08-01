(use-package project
  :ensure nil ;; builtin 
  :after consult
  :demand t
  :config
  (use-package consult-project-extra
    :config
    ;; TODO no sorting by recency in files?
    ;; suddenly started working though...
    (consult-customize
     consult-project-extra-find
     :preview-key "C-="))

  (defun consult-project-switch-project ()
    (interactive)
    (let ((default-directory (consult--read
                              (project-known-project-roots)
                              :prompt "Project: "
                              :category 'project)))
      (call-interactively 'magit)))
  
  (general-define-key
   :keymaps 'menu-project-map
   ;; TODO see if this works
   "w" 'menu-window-map
   "a" (** consult-ripgrep)
   "p" (** consult-project-switch-project)
   "d" (** project-find-dir)
   "f" (** consult-project-extra-find)
   )

  (general-define-key
   :keymaps 'menu-window-map
   "p" (** menu-project))
  )

;; TODO seems like this is under active development, just enabling,
;; but not using it yet
(use-package ede
  :ensure nil ;; builtin 
  :demand t
  :config
  (global-ede-mode))
