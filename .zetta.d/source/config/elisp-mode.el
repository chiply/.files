(use-package elisp-mode
  :straight nil
  :demand t

  :general
  (
   :states '(normal visual insert)
   :keymaps '(emacs-lisp-mode-map
              lisp-mode-map
              evil-lispy-mode-map
              lisp-interaction-mode-map)
   "<C-return>" 'eval-defun
   "<C-S-return>" 'eval-buffer
   )

  (
   :states '(normal visual)
   :keymaps '(emacs-lisp-mode-map
              lisp-mode-map
              evil-lispy-mode-map
              lisp-interaction-mode-map)
   "==" '(lambda () (interactive)
           (save-excursion
             (evil-indent (point-min) (point-max))))
   )
  )
