;; download from https://files.ax86.net/terminus-ttf/ drag it into the
;; `Font Book` app
(set-frame-font "Terminus (TTF)")

;; prevent the *Warnings* buffer from popping up
(setq warning-minimum-level :emergency)

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
;;(setq-default left-fringe-width 5)
;;(setq-default right-fringe-width 5)


(defun z-tab-bar-hydra ()
  (let ((icon (z-line-hydra-indicator-icon))) (when icon "H")))

(defun zmc-modeline-indicator ()
  (concat
   ;;"🏃‍♀️‍➡️"
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

;; some comment
(defun pom-ind ()
  ;; comment
  (when pom "🍅 "))

;;(defun repeat-indicator-icon ()
;;(if (and (boundp 'menu--indicator) menu--indicator) "** " "__ "))

(defun z-pyvenv-activate-poetry-modeline ()
  (and (boundp 'z-pyvenv-virtual-env)
       (concat "{venv:"
               (z-minify-path z-pyvenv-virtual-env)
               "/"
               (car (last (split-string z-pyvenv-virtual-env "/")))
               "}")))

(defun new-line () "\n")
(defun new-line-1 () "2")
(defun new-line-2 () "\n")

(defun z-nyan ()
  (nyan-create))

(defun z-current-prefix ()
  (let ((descr (key-description
                (or
                 (and
                  (boundp 'my-this-command-keys-vector)
                  my-this-command-keys-vector)
                 (this-command-keys-vector)))))
    (if (string-match-p "mouse" descr)
        ""
      descr
      )
    ))

;; otherwise prefix keys won't show up
(add-hook 'prefix-command-echo-keystrokes-functions 'force-mode-line-update)

(defun z-insert-space () " ")

;; in *scratch*:

(defun z-fish ()
  (concat fish-mode-line-string " "))

(defun z-tab-bar-spot-mode-line-string ()
  (if (fboundp 'spot-mode-line-string)
      (spot-mode-line-string)
    "*"))


(setq tab-bar-format '(;; everything here on will be aligned on the right
                       ;;z-tab-bar-hydra
                       zmc-modeline-indicator
                       z-pyvenv-activate-poetry-modeline
                       ;; doesn't work in tab bar as it doesn't get
                       ;; updated reliably... note that even when
                       ;; using the entry and exist hooks it doesn't
                       ;; work
                       ;;key-state
                       ;;z-nyan
                       new-line
                       z-tab-bar-spot-mode-line-string
                       new-line
                       tab-bar-format-align-right
                       z-fish
                       recursion-indicator--string
                       ;;"  "
                       pom-ind
                       tab-bar-format-global
                       repeat-indicator-icon
                       ;; these go together
                       ;; TODO add current map
                       internal-echo-keystrokes-prefix ;; universal arg
                       z-insert-space
                       z-current-prefix
                       ))

(set-face-attribute 'tab-bar nil :box nil :inherit nil :background brushup-bg-1_0)


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
(add-hook 'window-selection-change-functions (lambda (_) (force-mode-line-update)))
