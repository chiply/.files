(use-package avy
  :ensure (:wait t)
  :demand t
  :config
  (setq avy-ignored-modes
        '(image-mode doc-view-mode pdf-view-mode))

  (general-define-key :keymaps 'override
                      "s-o" 'evil-avy-goto-char-timer)

  :hook (use-package--avy--post-config . z-brushup))
