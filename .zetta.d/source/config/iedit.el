(use-package iedit
  :init
  (defun hydra-iedit-initiate ()
    (interactive)
    (when (not (and (boundp 'iedit-mode) iedit-mode))
      (iedit-mode))
    (hydra-iedit/body))

  (defun hydra-iedit-terminate ()
    (interactive)
    (when (and (boundp 'iedit-mode) iedit-mode)
      (iedit-mode))
    )


  :config
  (setq iedit-overlay-priority 100)

  ;;:brushup
  (add-to-list 'brushup-styles
               '(set-face-attribute 'iedit-occurrence nil
                                    :inherit nil
                                    :background (face-background 'highlight)))

  :hydra
  ;; feel is that you start the hydra with ,i.
  ;; to exit the hydra, press o
  ;; to exit iedit mode, press , int he hydra
  ;; of C-g while over any occurrence
  (defhydra+ hydra-iedit ()
    ("," hydra-iedit-terminate "exit" :exit t)
    ("o" nil :exit t)
    ("j" iedit-next-occurrence "next" :column "Navigation")
    ("k" iedit-prev-occurrence "prev")
    ("gg" iedit-goto-first-occurrence "first")
    ("G" iedit-goto-last-occurrence "last")
    ("f" iedit-show/hide-unmatched-lines "fold" :column "Visibility")

    ("t" iedit-toggle-selection "toggle" :column "Restrict")
    ("f" iedit-restrict-function "function")
    ("l" iedit-restrict-current-line "line")

    ("J" (lambda () (interactive) ( iedit-expand-down-to-occurence ) ))
    ("K" (lambda () (interactive) ( iedit-expand-up-to-occurence ) ))

    ("r" iedit-replace-occurrences "replace" :column "Edit")
    ("i" evil-insert "edit" :exit t))

  :general
  (
   :keymaps 'launch-map
   "i" 'hydra-iedit-initiate
   )
  

  :hook (use-package--iedit--post-config . z-brushup)
  )
