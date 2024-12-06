;;(set-frame-font "Vulf Mono Code")
(set-frame-font "PT Mono")

(winner-mode)

(global-auto-revert-mode 1) ;; you might not want this
(setq auto-revert-verbose nil) ;; or this

;; need t turn his on per mode, causes oo many issues
(global-visual-line-mode -1)

(pixel-scroll-precision-mode 1)

(setq scroll-margin 0 ;; setting this above 0 causes issues with jumping while scrolling
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

;;(defhydra+ hydra-window ()
;;("C-S" z-scratch :exit t)
;;("C-S-<backspace>" z-server-shutdown-save-desktop))

(general-define-key :keymaps 'menu-window-keymap
                    "C-S" 'z-scratch
                    "C-S-<backspace>" 'z-server-shutdown-save-desktop)

(setq-default left-margin-width 2)
(setq-default right-margin-width 2)

(defun z-tab-bar-hydra ()
  (let ((icon (z-line-hydra-indicator-icon))) (when icon "H")))

(defun zmc-modeline-indicator ()
  (concat
   "🏃‍♀️‍➡️"
   (when (boundp 'local-transient) local-transient)
   " "
   ;;" || " "🌎 "
   ;;(when (boundp 'latest-transient) latest-transient)
   ))

(setq pom nil)
(defun pomodoro! ()
  ;; toggle the value of global variable pom
  (interactive)
  (setq pom (not pom)))

(defun pom-ind ()
  (when pom "🍅 "))

(defun repeat-indicator-icon ()
  (if (and (boundp 'menu-indicator) menu-indicator) "** " "__ "))

(defun z-pyvenv-activate-poetry-modeline ()
  (and (boundp 'z-pyvenv-virtual-env)
       (concat "{venv:"
               (z-minify-path z-pyvenv-virtual-env)
               "/"
               (car (last (split-string z-pyvenv-virtual-env "/")))
               "}")))


(setq tab-bar-format '(;; everything here on will be aligned on the right
                       ;;z-tab-bar-hydra
                       zmc-modeline-indicator
                       z-pyvenv-activate-poetry-modeline
                       ;; doesn't work in tab bar as it doesn't get
                       ;; updated reliably... note that even when
                       ;; using the entry and exist hooks it doesn't
                       ;; work
                       ;;key-state
                       tab-bar-format-align-right
                       repeat-indicator-icon
                       recursion-indicator--string
                       "  "
                       pom-ind
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

;; activate makefile-mode whenver a file is opened matching the regex "Makefile.*"
(add-to-list 'auto-mode-alist '("Makefile.*" . makefile-mode))



