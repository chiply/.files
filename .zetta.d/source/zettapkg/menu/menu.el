;;; -*- lexical-binding: t -*-

;; TODO add which-key-like embark to the helpers for both menu and
;; versatile C-h

;; TODO add docstrings

;; DONE normalize helper keybindings bt menu and versatile C-h and
;; also make sure these are 'reserved' eg I'm not using them in any
;; menu

;; TODO switching between different types of help in menu is still
;; confusing / inconsistent this should get fixed in a deep dive.  May
;; need to settle on C-g'ing out of the menu, but maybe that's not
;; possible with which key

;; TODO refine which-key settings, can I display the keymap?

(defvar-keymap menu-active-km)
(defvar menu-indicator nil)
(defvar menu-which-key-toggle nil)
(defvar-local menu-minibuffer-km nil)

;; Help popups (design should work for both versatile-C-h and )
(defun menu-prefix-help-command-which-key (&optional km)
  (interactive)
  (let ((display-settings
         '((display-buffer-in-side-window) (window-height . 0.3))))
    (if menu-which-key-toggle
        (progn (kill-buffer which-key-buffer-name)
               (setq menu-which-key-toggle nil))
      (progn
        (which-key--create-buffer-and-show nil (or km menu-active-km))
        (display-buffer which-key--buffer display-settings)
        (setq menu-which-key-toggle t)))))


(defun menu-prefix-help-command-embark (&optional km)
  (interactive)
  (embark-bindings-in-keymap (or km menu-active-km)))


;; Menu code starts here
(defun menu-continue-p () t)


(defun menu-on-exit ()
  (setq menu-indicator nil menu-active-km nil menu-which-key-toggle nil)
  (force-mode-line-update)
  (which-key-abort))


(defun menu-set-transient-map (km)
  (set-transient-map km 'menu-continue-p #'menu-on-exit))


(defun menu-get-child-map (km)
  (let ((map (make-sparse-keymap))) (set-keymap-parent map km) map))


(defun menu-define-quitter-keys (km exit-function)
  (define-key km [remap keyboard-quit]
              (lambda () (interactive) (funcall exit-function)))
  (define-key km [remap keyboard-escape-quit]
              (lambda () (interactive) (funcall exit-function)))
  (define-key km [remap minibuffer-keyboard-quit]
              (lambda () (interactive) (funcall exit-function))))


(defun menu-define-helpers (km)
  "Note these need to be called without arguments, they effectively need to
detect the current km.  describe-prefix-bindings works because
overriding bindings are set"
  (define-key km (kbd "C-h") 'menu-prefix-help-command-embark)
  (define-key km (kbd "C-S-h") 'menu-prefix-help-command-which-key)
  (define-key km (kbd "M-S-h") 'describe-prefix-bindings))


;; Workhorse function
(defun menu (km)
  (let* ((transient-km (menu-get-child-map km))
         (exit-function (menu-set-transient-map transient-km)))
    (setq which-key-persistent-popup t)
    (setq menu-indicator t menu-active-km transient-km)
    (force-mode-line-update)
    (menu-define-quitter-keys transient-km exit-function)
    (menu-define-helpers transient-km)))


;; Hooks
(defun menu-suspend-transient-map ()
  (when menu-active-km
    (setq-local menu-minibuffer-km (copy-keymap menu-active-km))
    (setq overriding-terminal-local-map nil)))


(defun menu-restore-transient-map ()
  (when (keymapp menu-minibuffer-km) (menu menu-minibuffer-km)))


(add-hook 'minibuffer-setup-hook 'menu-suspend-transient-map)
(add-hook 'minibuffer-exit-hook 'menu-restore-transient-map)


;; Macro
(defmacro defmenu (function-name km-name)
  `(progn
     (defvar ,km-name (make-sparse-keymap))
     (defun ,function-name () (interactive) (menu ,km-name))))


;; TODO factor out?  decouple from which-key?
(defun versatile-C-h ()
  (interactive)
  (let* ((keys (this-command-keys-vector))
         (prefix (seq-take keys (1- (length keys))))
         (orig-km (key-binding prefix 'accept-default))
         (km (copy-keymap orig-km))
         (key (read-key "C-h, C-S-h, M-h, or M-S-h: ")))
    (setq which-key-persistent-popup nil)
    (cond ((eq key ?\C-h) (menu-prefix-help-command-embark km))
          ((eq key ?\C-\S-h) (menu-prefix-help-command-which-key km))
          ((eq key ?\M-h) (menu km))
          ;;((eq key ?\M-\S-h) (describe-prefix-bindings)) ;; TODO invalid seq
          (t (message "Invalid key")))))


(provide 'menu)
