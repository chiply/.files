(use-package projectile
  :config
  (setq projectile-cache-file (expand-file-name ".data/projectile/projectile.cache" user-emacs-directory)
        (project-known-project-roots)-file (expand-file-name ".data/projectile/projectile-bookmarks.eld" user-emacs-directory)
        projectile-completion-system 'auto
        projectile-project-root-files-bottom-up
        '(".projectile" ".git"))
  (projectile-global-mode)

  :hydra
  (defhydra+ hydra-window ()
    ("p" hydra-projectile/body :exit t)
    )
  (defhydra+ hydra-projectile ()
    ("w" hydra-window/body :exit t)
    ("A"   (lambda () (interactive)
             (let ((current-prefix-arg '(4)))
               (call-interactively 'consult-ripgrep)
               )
             ) "rg - dir" :exit t :column "grep") 
    ("a"   consult-ripgrep "rg" :exit t :column "grep") 
    ("o"   projectile-multi-occur "occur" :exit t) 

    ("p"   projectile-switch-project "switch project" :exit t :column "Goto")
    ("d"   projectile-find-dir "dir")
    ("f"   project-find-file "file") 
    ("r"   projectile-recentf "recent")


    ("K"   projectile-kill-buffers "kill project buffers" :exit t :column "Misc")
    )
  )
