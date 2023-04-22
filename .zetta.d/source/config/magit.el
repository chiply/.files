(use-package compat
  :demand t)

(use-package magit
  :init
  (setq magit-branch-read-upstream-first 'fallback)

  (defun z-magit-project ()
    (interactive)
    (let ((dir (completing-read "Project: " (projectile-relevant-known-projects))))
      (magit-status dir)
      )
    )

  (defhydra+ hydra-magit ()
    ("g" magit-status :exit t)
    ("B" magit-branch :exit t)
    ("b" magit-blame :exit t)
    ("t" magit-tag :exit t)
    ("s" magit-stage :exit t)
    ("S" magit-stage-modified :exit t)
    ("p" magit-push :exit t)
    ("c" magit-commit :exit t)
    ("l" magit-log :exit t)
    ("r" magit-show-refs :exit t)
    ("d" vc-diff :exit t)
    ("f" magit-fetch :exit t)
    ("p" magit-pull :exit t)
    )


  :display
  (z-side "\\magit-status-mode" 'right 0)
  (z-side "\\magit-diff-mode" 'right 2)
  (z-side "\\magit-log-mode" 'right 1)
  (z-side "\\magit-refs-mode" 'right 1)
  (z-side "\\magit-revision-mode" 'right 2)


  :general
  (
   :keymaps 'text-mode-map
   :states '(normal visual insert)
   "C-<return>" 'with-editor-finish
   ) 
  (
   :states '(normal visual)
   :keymaps 'override
   :prefix ","
   "g" 'hydra-magit/body
   "G" 'z-magit-project
   )
  (
   :states '(normal visual insert)
   :keymaps '(magit-status-mode-map)
   "C-<tab>" 'tab-line-switch-to-next-tab
   "C-S-<tab>" 'tab-line-switch-to-prev-tab
   )
  )
