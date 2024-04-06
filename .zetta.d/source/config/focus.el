(use-package focus
  ;; need to load the funcitons as super structure nav relies
  :demand t

  :init
  (defun z-focus-mode (thing)
    "Thing is a quoted symbol"
    ;;(focus-mode)
    (setq-local focus-current-thing thing))


  :brushup
  (add-to-list
   'brushup-styles
   '(progn
      (set-face-attribute 'focus-unfocused nil
                          :height 1.0
                          :foreground
                          (if brushup-dark-p
                              (color-lighten-name brushup-bg 20)
                            (color-lighten-name brushup-bg -20)))
      (set-face-attribute 'focus-focused nil
                          :height 1.0
                          )
      )
   )


  :hydra
  (defhydra+ hydra-focus ()
    
    ("j" focus-next-thing "Next" :column "Navigate")
    ("k" focus-prev-thing "Prev")
    ("F" focus-mode "Toggle" :column "Mode")
    ("n" focus-change-thing "Change scope")
    ("p" focus-pin "Pin" :column "Pin")
    ("P" focus-unpin "Unpin")
    )

  (defhydra+ hydra-window ()
    ("C-f" focus-mode "Next")
    )


  :hook ((emacs-lisp-mode . (lambda () (z-focus-mode 'defun)))
         ((python-ts-mode sql-mode yaml-mode sh-mode) . (lambda () (z-focus-mode 'brick)))
         (use-package--focus--post-config . (lambda () (z-brushup))))
  )
