(use-package consult
  :config

  
  (recentf-mode)
  
  (setq recentf-save-file (expand-file-name ".data/recentf/recentf" user-emacs-directory))
  (setq consult-project-root-function #'projectile-project-root
        consult-narrow-key "<"
        ;; IMPORTANT!  otherwise completion-at-point doesn't use vertico!
        completion-in-region-function 'consult-completion-in-region)

  (setq
   consult-ripgrep-args
   "rg --hidden --glob \"!.git\" --null --line-buffered --color=never --max-columns=1000 --path-separator /   --smart-case --no-heading --line-number ."
   )

  (defun z-consult-ripgrep (&optional arg)
    (interactive "P")
    (let ((consult-preview-key "M-."))
      (call-interactively 'consult-ripgrep)))

  (consult-customize
   consult-ripgrep
   consult-buffer
   ;; need to use the actual name of the function, even if it wraps a
   ;; consult-* function
   ;;z-consult-ripgrep
   consult-bookmark
   consult-project-buffer
   org-roam-node-insert
   ;;z-org-roam-node-find
   ;;z-org-roam-capture
   :preview-key (kbd "M-.")
   )

  :hydra
  (defhydra+ hydra-window ()
    ("s" z-consult-ripgrep :exit t)
    ("S" consult-line :exit t)
    )

  :general
  (
   :keymaps 'evil-insert-state-map
   (general-chord ",v") 'consult-yank-from-kill-ring
   (general-chord ",s") 'z-consult-ripgrep
   )
  (
   :states '(normal visual)
   :keymaps 'override
   :prefix ","
   "v" 'consult-yank-from-kill-ring
   "s" 'z-consult-ripgrep
   ;; weird that I still have to set the preview key
   "S" 'consult-line
   )
  )

(use-package consult-dir)

(use-package consult-org-roam
  :config
  (consult-org-roam-mode))
