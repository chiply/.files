(use-package vc
  :straight nil
  :demand t

  :config
  (setq vc-follow-symlinks t)

  :evil
  (evil-set-initial-state 'magit-blame-mode 'emacs)
  (evil-set-initial-state 'git-commit-mode 'emacs)
  (evil-set-initial-state 'git-blame-mode 'emacs)
  (evil-set-initial-state 'git-commit-mode 'insert)
  (evil-set-initial-state 'magit-log-edit-mode 'insert)


  :display

  (z-side "^\\*vc-diff*" 'right)

  :hook (
         ((diff-mode magit-status-mode magit-diff-mode git-commit-mode) . (lambda () (text-scale-set -2)))
         )
  )




