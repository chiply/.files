(set-frame-font "PT Mono")

(setq auto-window-vscroll nil)

(global-auto-revert-mode 1) ;; you might not want this
(setq auto-revert-verbose nil) ;; or this

;; need t turn his on per mode, causes oo many issues
(global-visual-line-mode -1)

(pixel-scroll-precision-mode 1)

(setq scroll-margin 5
      scroll-conservatively 9999
      scroll-step 1)



(defun server-shutdown ()
  "Save buffers, Quit, and Shutdown (kill) server"
  (interactive)
  (save-some-buffers)
  (kill-emacs)
  )

(defun z-scratch ()
  (interactive)
  (let* ((major-mode-input (completing-read "Enter a major mode: "
                                            '("python" "sql" "elisp"))))
    (switch-to-buffer (concat "*" major-mode-input "-scratch" "*"))
    (when (string= major-mode-input "python") (python-mode))
    (when (string= major-mode-input "sql") (sql-mode))
    (when (string= major-mode-input "elisp") (emacs-lisp-mode))
    ))



(setq enable-local-variables :all)




(defhydra+ hydra-window ()
  ("C-S" z-scratch :exit t)
  ("C-S-<backspace>" z-server-shutdown-save-desktop)
  )






