(use-package consult
  :config

  (recentf-mode)
  
  (setq recentf-save-file (expand-file-name ".data/recentf/recentf" user-emacs-directory))
  (setq consult-project-root-function #'projectile-project-root
        ;;consult-narrow-key "<"
        consult-narrow-key nil
        ;; IMPORTANT!  otherwise completion-at-point doesn't use vertico!
        completion-in-region-function 'consult-completion-in-region)

  (setq
   consult-ripgrep-args
   "rg --hidden --glob \"!.git\" --null --line-buffered --color=never --max-columns=1000 --path-separator / --smart-case --no-heading --line-number")

  (consult-customize
   consult-ripgrep
   consult-buffer
   consult-bookmark
   consult-project-buffer
   :preview-key "C-+")
  
  :hydra
  (defhydra+ hydra-window ()
    ("s" consult-ripgrep :exit t)
    ("S" consult-line :exit t))

  :general
  (
   :keymaps 'launch-map
   "v" 'consult-yank-from-kill-ring
   "s" 'consult-ripgrep
   "S" 'consult-line
   )
  ;;(
   ;;:keymaps '(meow-motion-state-keymap meow-normal-state-keymap meow-beacon)
   ;;"/" 'consult-line
   ;;;; left off -- add reverse mode and test this out --- could be close-ish to what i want
   ;;)
  )

(use-package consult-dir)

