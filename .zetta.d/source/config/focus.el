(use-package focus
  ;; need to load the funcitons as super structure nav relies
  :demand t

  :init
  (defun z-focus-mode (thing)
    "Thing is a quoted symbol"
    (setq-local focus-current-thing thing))


  :brushup
  (add-to-list
   'brushup-styles
   '(progn
      (set-face-attribute 'focus-unfocused nil
                          ;;:height 1.0
                          :foreground
                          (if brushup-dark-p
                              (color-lighten-name brushup-bg 20)
                            (color-lighten-name brushup-bg -35)))
      ;;(set-face-attribute 'focus-focused nil :height 1.0)
      ))

  (add-to-list 'focus-mode-to-thing '(python-ts-mode . lsp-folding-range))


  :general
  (
   :keymaps 'menu-window-map
   "C-f" (** focus-mode)
   )


  ;;:hook (((prog-mode) . (lambda () (focus-mode)))
         ;;(emacs-lisp-mode . (lambda () (z-focus-mode 'defun)))
         ;;((python-ts-mode sql-mode yaml-mode sh-mode) . (lambda () (z-focus-mode 'defun))))
  ;;(use-package--focus--post-config . (lambda () (z-brushup))))
  )
