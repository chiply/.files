(use-package pyvenv
  :init
  (pyvenv-mode))

(use-package python
  :straight nil

  :config
  (setq python-shell-interpreter "python3")

  ;; Debugging
  (require 'dap-python)

  (setq dap-python-executable "python3")
  (setq dap-python-debugger 'debugpy)
  ;; feels hacky
  (defun dap-python--pyenv-executable-find (command)
    (concat pyvenv-virtual-env "bin/python3")
    )


  :general
  (
   :states '(normal visual)
   :keymaps 'python-mode-map
   "==" '(lambda () (interactive)
           (save-excursion
             (evil-indent (point-min) (point-max))))
   )

  :hook (
         (python-mode . flycheck-mode)
         (python-mode . dap-ui-mode)
         (python-mode . dap-mode)
         (dap-stopped . (lambda (arg) (call-interactively #'dap-hydra)))
         )
  )

;; autoformatting
(use-package blacken)

