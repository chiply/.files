(use-package consult
  ;;:ensure (consult :type git :host github :repo "minad/consult" :tag "1.9")
  :config

  (recentf-mode)
  
  (setq recentf-save-file (expand-file-name ".data/recentf/recentf" user-emacs-directory))
  (setq consult-project-root-function #'(project-root (project-current nil default-directory))
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
   ;;consult-yank-pop
   :preview-key "C-+")
  

  ;; project.el
  ;; TODO don't like how verbose and multi-step this is.
  (keymap-substitute project-prefix-map #'project-find-regexp #'consult-ripgrep)
  (cl-nsubstitute-if
   '(consult-ripgrep "Find regexp")
   (pcase-lambda (`(,cmd _)) (eq cmd #'project-find-regexp))
   project-switch-commands)
  
  ;;:hydra
  ;;(defhydra+ hydra-window ()
  ;;("s" consult-ripgrep :exit t)
  ;;("S" consult-line :exit t))

  :general
  (:keymaps 'override
            "M-y" 'consult-yank-pop)
  (
   :keymaps 'menu-window-keymap
   "s" 'consult-ripgrep
   "S" 'consult-line
   )
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

