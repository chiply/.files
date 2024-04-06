(use-package avy
  :config
  (setq avy-ignored-modes '(image-mode
                            doc-view-mode
                            pdf-view-mode
                            shell-mode
                            vterm-mode))

  :general
  (
   :keymaps 'launch-map
   "j" 'hydra-evil-avy/body
   )

  :hydra
  (defhydra+ hydra-evil-avy ()
    ("w" evil-avy-goto-word-0 "Go to word" :exit t)
    ("j" evil-avy-goto-word-1 "Go to word 1" :exit t)
    ("c" evil-avy-goto-char "Go to char" :exit t)
    ("W" evil-avy-goto-line "Go to line" :exit t)
    )

  :hook (use-package--avy--post-config . z-brushup)

  )
