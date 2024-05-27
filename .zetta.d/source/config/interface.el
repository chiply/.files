;; TODO: some todo
(set-frame-font "Vulf Mono")


(winner-mode)


(global-auto-revert-mode 1) ;; you might not want this
(setq auto-revert-verbose nil) ;; or this

;; need t turn his on per mode, causes oo many issues
(global-visual-line-mode -1)

(pixel-scroll-precision-mode 1)

(setq scroll-margin 5
      scroll-conservatively 9999
      scroll-step 1)

(setq scroll-bar-width nil)
(setq scroll-bar-height nil)


(defun server-shutdown ()
  "Save buffers, Quit, and Shutdown (kill) server"
  (interactive)
  (save-some-buffers)
  (kill-emacs))

(defun z-scratch ()
  (interactive)
  (let* ((major-mode-input (completing-read "Enter a major mode: "
                                            '("python" "sql" "elisp"))))
    (switch-to-buffer (concat "*" major-mode-input "-scratch" "*"))
    (when (string= major-mode-input "python") (python-ts-mode))
    (when (string= major-mode-input "sql") (sql-mode))
    (when (string= major-mode-input "elisp") (emacs-lisp-mode))))

(setq enable-local-variables :all)

(defhydra+ hydra-window ()
  ("C-S" z-scratch :exit t)
  ("C-S-<backspace>" z-server-shutdown-save-desktop))

(setq-default left-margin-width 2)
(setq-default right-margin-width 2)

(defun z-tab-bar-hydra ()
  (let ((icon (z-line-hydra-indicator-icon))) (when icon "H"))
  )


;; (defun key-state ()
;;   (concat
;;    (or
;;     (when (and (boundp 'evil-mode) evil-mode) (all-the-icons-icon-for-mode 'evil-state))
;;     (when (and (boundp 'meow-mode) meow-mode) (all-the-icons-icon-for-mode 'meow-state))
;;     (when (not (or (and (boundp 'evil-mode) evil-mode)
;;                    (and (boundp 'meow-mode) meow-mode)))
;;       (all-the-icons-icon-for-mode 'emacs-state)))
;;    (or
;;     (when (or (and (boundp 'meow-insert-mode) meow-insert-mode)
;;               (and (boundp 'evil-insert-state-minor-mode) evil-insert-state-minor-mode))
;;       (all-the-icons-icon-for-mode 'insert-state))
;;     (when (and
;;            ;; in either evil or meow
;;            (or (and (boundp 'evil-mode) evil-mode)
;;                (and (boundp 'meow-mode) meow-mode))
;;            ;; and insert state is not active
;;            (not (or (and (boundp 'meow-insert-mode) meow-insert-mode)
;;                     (and (boundp 'evil-insert-state-minor-mode) evil-insert-state-minor-mode))))
;;       (all-the-icons-icon-for-mode 'non-insert-state)))
;;    )
;;   )

;; (force-mode-line-update-all)
;; (defun force-mode-line-update-all ()
;;   (force-mode-line-update t))

;; (add-hook 'evil-insert-state-entry-hook 'force-mode-line-update-all)
;; (add-hook 'evil-insert-state-exit-hook 'force-mode-line-update-all)
;; (add-hook 'meow-insert-state-entry-hook 'force-mode-line-update-all)
;; (add-hook 'meow-insert-state-exit-hook 'force-mode-line-update-all)



(setq tab-bar-format '(;; everything here on will be aligned on the right
                       ;;z-tab-bar-hydra
                       ;; doesn't work in tab bar as it doesn't get
                       ;; updated reliably... note that even when
                       ;; using the entry and exist hooks it doesn't
                       ;; work
                       ;;key-state
                       tab-bar-format-align-right
                       recursion-indicator--string
                       "  "
                       tab-bar-format-global
                       ))

;; Emacs 28 and newer: Hide commands in M-x which do not work in the current
;; mode.  Vertico commands are hidden in normal buffers. This setting is
;; useful beyond Vertico.
(setq read-extended-command-predicate #'command-completion-default-include-p)


;; note can change the minibuffer font in this way.  not doing this
;; for now because the echo area height is determined by teh default
;; font size.  so when there is a short default font and the font set
;; here is taller, then the minibuffer resizes whenever it gets used,
;; causign jitter in the interface
;; (add-hook 'minibuffer-setup-hook 'my-buffer-face-mode-pt-mono-p85)




