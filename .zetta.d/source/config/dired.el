(use-package dired
  :straight (:type built-in)


  :init
  (z-load-extension-file "dired/dired.el")

  :display
  (z-side "\\dired-mode" 'left 1 0.10)

  :hydra
  (defhydra+ hydra-run ()
    ("d" (lambda ()
           (interactive)
           (z-soda-drink
            (quote z-soda-create-and-display-dired)
            "dired-mode"))
     "Dired")
    ("D" (lambda () (interactive) (z-soda-cap "\\dired-mode*" 1)) "Dired" )
    )

  :general
  (
   :states '(normal visual insert)
   :keymaps '(dired-mode-map)
   "<tab>" 'z-dired-subtree-toggle
   "S-<tab>" 'z-dired-subtree-cycle
   "o" 'dired-ace-find-file
   "v" 'dired-ace-find-file-vert
   "h" 'dired-ace-find-file-hor
   "O" 'dired-ace-new-file
   "V" 'evil-visual-line
   "H" 'dired-ace-new-file-hor
   "J" 'dired-subtree-down
   "K" 'dired-subtree-up
   "p" 'z-dired-file-peak
   "A" 'z-dired-ag
   "r" 'revert-buffer
   "R" 'z-dired-do-rename
   "x" 'z-dired-do-flagged-delete
   "D" 'z-dired-do-delete
   "C" 'z-dired-do-copy
   "+" 'z-dired-create-directory
   "y" 'evil-yank
   "Y" 'z-dired-ranger-copy
   "P" 'z-dired-ranger-paste
   "M" 'z-dired-ranger-move
   "B" 'z-dired-open-in-chrome
   "gg" 'evil-goto-first-line
   "G" 'evil-goto-line
   "<C-return>" 'xah-open-in-external-app
   )

  :hook (
         (dired-mode . (lambda () (dired-hide-details-mode 1)))
         (dired-mode . (lambda () (text-scale-set -2)))
         )
  )










