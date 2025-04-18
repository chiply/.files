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
  :config
  (setq z-parrot-window nil)
  (setq z-parrot-buffer nil)
  (defun z-animate-parrot ()
    (interactive)
    (setq z-parrot-window (selected-window))
    (setq z-parrot-buffer (current-buffer))
    (parrot-start-animation)
    )

  ;; NOTE overwriting function in parrot.el, my custom functions
  ;; ensures the parrot only animates in the selected buffer/window
  (defun parrot--progress ()
    "Start a persistent parrot animation.
Use `parrot-progress-finished' to stop."
    (z-animate-parrot))

  
  :hook
  ((magit-status-mode . (lambda () (parrot-mode) (parrot-stop-animation)))
   (org-mode . (lambda () (parrot-mode) (parrot-stop-animation)))))


