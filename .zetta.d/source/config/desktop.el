(use-package desktop
  :straight nil
  :config
  (setq desktop-base-file-name (expand-file-name ".data/desktop/.emacs.desktop" user-emacs-directory))
  (setq desktop-restore-frames nil)
  (setq desktop-load-locked-desktop t)
  (desktop-save-mode 1)

  (defun z-desktop-buffers-not-to-save-function (fnm bufnm mode &rest rest)
    nil
    )
  (setq desktop-buffers-not-to-save-function 'z-desktop-buffers-not-to-save-function)

  (defun z-desktop-save ()
    (interactive)
    (desktop-save "~/.files/.zetta.d/"))

  (defun z-server-shutdown-save-desktop ()
    (interactive)
    (z-desktop-save)
    (server-shutdown))
  )
