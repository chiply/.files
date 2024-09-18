(use-package compat
  :demand t)

(use-package magit
  :init
  (setq magit-branch-read-upstream-first 'fallback)
  ;; TODO change
  (setq magit-process-popup-time -1)

  (defun z-magit-project ()
    (interactive)
    (let ((dir (completing-read "Project: " (project-known-project-roots))))
      (magit-status dir)))

  (setq magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1)

  :config
  (require 'magit-margin)
  (require 'magit-section)

  (setq magit-log-margin-show-shortstat t)
  (setq magit-status-margin '(t age-abbreviated magit-log-margin-width nil 6))
  (setq magit-log-margin '(t age-abbreviated magit-log-margin-width nil 6))
  (add-hook 'magit-status-mode-hook 'magit-toggle-log-margin-style)
  (add-hook 'magit-log-mode-hook 'magit-toggle-log-margin-style)

  (general-unbind :keymaps 'magit-status-mode-map :states 'normal "M-<tab>")
  (general-unbind :keymaps 'magit-mode-map :states 'normal "M-<tab>")
  (general-unbind :keymaps 'magit-section-mode-map :states 'normal "M-<tab>")

  (general-unbind :keymaps 'magit-status-mode-map :states 'normal "C-<tab>")
  (general-unbind :keymaps 'magit-mode-map :states 'normal "C-<tab>")
  (general-unbind :keymaps 'magit-section-mode-map :states 'normal "C-<tab>")

  ;; overriding here -- basically not setting to width of shortstat as
  ;; that ends up cutting off the margin value for forge data

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
    ("p" magit-pull :exit t))

  ;;:display
  ;;;;(z-side "\\magit-status-mode" 'right 0)
  ;;(z-side "\\magit-diff-mode" 'right 2)
  ;;;;(z-side "\\magit-log-mode" 'right 1)
  ;;;;(z-side "\\magit-refs-mode" 'right 1)
  ;;;;(z-side "\\magit-revision-mode" 'right 2)


  :general
  (
   :keymaps 'launch-map
   "g" 'hydra-magit/body
   "G" 'z-magit-project
   )
  (
   :keymaps 'text-mode-map
   "C-<return>" 'with-editor-finish
   ) 
  (
   :keymaps '(magit-status-mode-map magit-process-mode-map)
   "C-<tab>" 'tab-line-switch-to-next-tab
   "C-S-<tab>" 'tab-line-switch-to-prev-tab
   "M-S-<tab>" 'st-switch-space-by-name
   "M-<tab>" 'st-go-to-last-space
   )

  )


