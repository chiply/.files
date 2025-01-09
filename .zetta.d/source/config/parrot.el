(use-package parrot
  :demand t
  :ensure (parrot :type git :host github :repo "positron-solutions/parrot")
  :custom
  (parrot-animate 'hide-static)
  (parrot-rotate-animate-after-rotation nil)
  (parrot-num-rotations 4)
  (parrot-party-on-org-todo-states '("DONE"))
  ;; NOTE I get issues with the othertypes
  (parrot-type 'default)
  ;;(parrot-animate-on-load t)
  ;;(parrot-mode t)
  :hook
  ((magit-status-mode . (lambda () (parrot-mode) (parrot-stop-animation)))
   (org-mode . (lambda () (parrot-mode) (parrot-stop-animation)))))


