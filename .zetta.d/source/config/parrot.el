(use-package parrot
  :straight
  (parrot :type git :host github :repo "positron-solutions/parrot")
  :custom
  (parrot-animate 'hide-static)
  (parrot-rotate-animate-after-rotation nil)
  (parrot-num-rotations 4)
  (parrot-type 'emacs)
  (parrot-animate-on-load t)
  (parrot-mode t))


