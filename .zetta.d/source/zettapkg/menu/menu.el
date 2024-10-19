;;; -*- lexical-binding: t -*-

;; TODO experiment with a continue function that quits if something
;; not in keymap is pressed TODO make this configuration

(defvar-keymap menu-active-keymap)
(defvar menu-indicator nil)
(defvar menu-which-key-toggle nil)
(defvar-local menu-minibuffer-keymap nil)
(defvar menu-exit-message ">>Exited Repeat Mode!<<")
(defvar menu-enter-message ">>Entered Repeat Mode!<<")

;; Helpers (TODO move to config)
(defun menu-prefix-help-command-which-key ()
  (interactive)
  (if menu-which-key-toggle
      (progn
        (kill-buffer which-key-buffer-name)
        (setq menu-which-key-toggle nil))
    (progn
      (which-key--create-buffer-and-show
       nil menu-active-keymap)
      (display-buffer
       which-key--buffer
       '((display-buffer-in-side-window)
         (side . bottom)
         (window-height . 0.3)))
      (setq menu-which-key-toggle t))))

(defun menu-prefix-help-command-embark (&optional keymap)
  (interactive)
  (embark-bindings-in-keymap (or keymap menu-active-keymap)))

(defun versatile-C-h ()
  (interactive)
  (let* ((keys (this-command-keys-vector))
         (prefix (seq-take keys (1- (length keys))))
         (orig-keymap (key-binding prefix 'accept-default))
         (km (copy-keymap orig-keymap))
         ;; order matters
         (key (read-key "h, H, or C-h: ")))
    (setq which-key-persistent-popup nil)
    ;;(setq which-key-use-C-h-commands t)
    (cond
     ((eq key ?h) (menu-prefix-help-command-embark km))
     ((eq key ?H) (menu-prefix-help-command-which-key))
     ((eq key ?\C-h) (describe-prefix-bindings))
     ((eq key ?\M-h) (menu-from-keymap km))
     (t (message "Invalid key")))))

;; Menu code starts here
(defun menu-continue-p () t)
(defun menu-on-exit ()
  (setq menu-indicator nil menu-active-keymap nil
        menu-which-key-toggle nil)
  (force-mode-line-update)
  (message menu-exit-message)
  (which-key-abort))

(defun menu-set-transient-map (keymap)
  (set-transient-map keymap 'menu-continue-p #'menu-on-exit))

(defun menu-get-child-map (keymap)
  (let ((map (make-sparse-keymap)))
    (set-keymap-parent map keymap)
    map))

(defun menu-define-quitter-keys (keymap exit-function)
  (define-key keymap
              [remap keyboard-quit]
              (lambda () (interactive) (funcall exit-function)))
  (define-key keymap
              [remap keyboard-escape-quit]
              (lambda () (interactive) (funcall exit-function)))
  (define-key keymap
              [remap minibuffer-keyboard-quit]
              (lambda () (interactive) (funcall exit-function))))

(defun menu-define-helpers (keymap)
  (define-key keymap (kbd "C-h") 'menu-prefix-help-command-embark)
  (define-key keymap (kbd "C-p") 'versatile-C-h)
  (define-key keymap (kbd "C-S-p") 'describe-prefix-bindings)
  (define-key keymap (kbd "C-S-h") 'menu-prefix-help-command-which-key)
  )

;; Workhorse function
(defun menu-from-keymap (keymap)
  (message menu-enter-message)
  (let* ((transient-keymap (menu-get-child-map keymap))
         (exit-function (menu-set-transient-map transient-keymap)))
    (setq which-key-persistent-popup t)
    (setq menu-indicator t menu-active-keymap transient-keymap)
    (force-mode-line-update)
    (menu-define-quitter-keys transient-keymap exit-function)
    (menu-define-helpers transient-keymap)))


(defun menu-from-keymap-onthefly ()
  (interactive)
  (when-let* ((keys (this-command-keys-vector))
              (prefix (seq-take keys (1- (length keys))))
              (orig-keymap (key-binding prefix 'accept-default))
              (km (copy-keymap orig-keymap)))
    (menu-from-keymap km)))


;; Hooks
(defun menu-suspend-transient-map ()
  (when menu-active-keymap
    (progn
      (setq-local menu-minibuffer-keymap
                  (copy-keymap menu-active-keymap))
      (setq overriding-terminal-local-map nil))))


(defun menu-restore-transient-map ()
  (when (keymapp menu-minibuffer-keymap)
    (menu-from-keymap menu-minibuffer-keymap)))


(add-hook 'minibuffer-setup-hook 'menu-suspend-transient-map)
(add-hook 'minibuffer-exit-hook 'menu-restore-transient-map)


;; Macro
(defmacro defmenu (function-name keymap-name)
  `(progn
     (defvar ,keymap-name (make-sparse-keymap))
     (defun ,function-name ()
       (interactive)
       (menu-from-keymap ,keymap-name))))

;; NOTE: design note, could make the macro insert 'menu' and 'keymap'.
;; Could also eliminate the keymap argument. That would make the calls
;; as simple as possible (defmenu window "w").  While this would lead
;; to nice syntax, I like the current setup because the _SYMBOLS_ in
;; the macro become the of the function and keymap that will be used
;; in *-define-key forms.  This is a very deliberate design choice and
;; should not be changed...

(provide 'menu)



