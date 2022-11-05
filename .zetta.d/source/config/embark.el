(use-package embark
  :demand t
  :config
  (defun embark-act-noquit ()
    "Run action but don't quit the minibuffer afterwards."
    (interactive)
    (let ((embark-quit-after-action nil))
      (embark-act)))

  ;; when displaying in side buffer
  (setq embark-verbose-indicator-display-action
        '((display-buffer-in-side-window)
          (side . right)
          (slot . 99)
          (width . 0.25)
          (height . 0.3)))

  (setq embark-indicators '(embark-verbose-indicator embark-highlight-indicator))

  ;; from https://karthinks.com/software/fifteen-ways-to-use-embark/
  (eval-when-compile
    (defmacro my/embark-ace-action (fn)
      `(defun ,(intern (concat "my/embark-ace-" (symbol-name fn))) ()
         (interactive)
         (with-demoted-errors "%s"
           (require 'ace-window)
           (let ((aw-dispatch-always t))
             (aw-switch-to-window (aw-select nil))
             (call-interactively (symbol-function ',fn)))))))

  (define-key embark-file-map     (kbd "o") (my/embark-ace-action find-file))
  (define-key embark-buffer-map   (kbd "o") (my/embark-ace-action switch-to-buffer))
  (define-key embark-bookmark-map (kbd "o") (my/embark-ace-action bookmark-jump))
  
  :display
  (z-side "^\\*Embark Collect*" 'right -1 0.25)
  (z-side "^\\*Embark Export Variables*" 'right -1 0.25)
  ;; not setting export bc theoretically it is in a specific mode
  ;; (z-side "^\\*Embark Export*" 'top)

  :general
  (
   :keymaps '(override)
   :states '(normal visual)
   "C-." 'embark-act
   "C->" 'embark-act-noquit
   )
  (
   :keymaps '(vertico-map)
   "C-." 'embark-act
   "C->" 'embark-act-noquit
   )
  )



