;; write a function that finds the first parent directory with a pyproject.toml
;; the function should return nil if no such directory is found
(defun z-find-poetry-project-root ()
  (interactive)
  (let ((dir (file-name-directory (buffer-file-name))))
    (while (and
            dir
            (not (file-exists-p (concat dir "pyproject.toml")))
            (not (string= dir "/")))
      (setq dir (file-name-directory (directory-file-name dir))))
    (if (string= dir "/") nil dir)))

(use-package pyvenv
  :after lsp-mode
  :init
  (pyvenv-mode)
  :config
  ;;(setq pyvenv-post-activate-hooks '())
  (defun z-pyvenv-activate-poetry ()
    (interactive)
    (when (and (eq major-mode 'python-ts-mode)
               (z-find-poetry-project-root))
      (if (and (boundp 'z-pyvenv-virtual-env) z-pyvenv-virtual-env)
          (pyvenv-activate z-pyvenv-virtual-env)
        (let* ((_ (pyvenv-deactivate))
               (cmd "poetry env info --path")
               (output (shell-command-to-string cmd))
               (venv (replace-regexp-in-string "\n" "" output)))
          (pyvenv-activate venv)
          (setq-local z-pyvenv-virtual-env venv)))
      (unless lsp-mode (lsp-deferred))))
  (add-hook 'buffer-list-update-hook 'z-pyvenv-activate-poetry))

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

