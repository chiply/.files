(use-package pyvenv
  :init
  (pyvenv-mode))

(use-package poetry)

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
   :keymaps 'python-ts-mode-map
   "C-c =" '(lambda () (interactive)
              (save-excursion
                (evil-indent (point-min) (point-max))))
   )

  :hook (
         (python-ts-mode . flycheck-mode)
         (python-ts-mode . dap-ui-mode)
         (python-ts-mode . dap-mode)
         (dap-stopped . (lambda (arg) (call-interactively #'dap-hydra)))
         )
  )

;; autoformatting
(use-package blacken)


;; not the greatest, but it's one of the better solutions that
;; actually supports type hinting
(use-package numpydoc
  :config
  (setq numpydoc-insertion-style nil)
  :bind (:map python-ts-mode-map
              ("C-c C-n" . numpydoc-generate)))

