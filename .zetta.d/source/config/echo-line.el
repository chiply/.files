;; (defun my-message-advice (orig-fun &rest args)
;;   (if (active-minibuffer-window)
;;       (apply orig-fun args)
;;     (if message-log-max
;;         (let ((inhibit-message t)) (apply orig-fun (list msg))))
;;     (let* ((msg (if (and args (stringp (car args)))
;;                     (concat (car args) " \n---")
;;                   "\n---"))
;;            (new-args (cons msg (cl-rest args))))
;;       ;; TODO explicitly set current message?
;;       (apply orig-fun new-args)
;;       )))

;; (advice-add 'message :around #'my-message-advice)
;; (advice-remove 'message 'my-message-advice)

;; (defun clear-minibuffer-message-1 () (setq minibuffer-message-overlay "\n---"))

;; (setq clear-minibuffer-function 'clear-minibuffer-message-1)
;; (setq clear-message-function 'clear-minibuffer-message-1)

;; (defun my-function ()
;;   (let ((message-log-max nil))
;;     (message (current-message))))

;; (add-hook 'post-command-hook 'my-function)
;; (remove-hook 'post-command-hook 'my-function)

;; TODO looks like key-chord is causing some flickering
;; TODO this could be due to sleep being used
;; TODO corfu is also causing some flickering, but no high increase/decrease
;; TODO changing echo area height when returning to active-minibuffer-window; could use minibuffer face and resize-mini-windows t? would that cause the height of the miniwindow to increase?


;; NOTE doesn't work well by default, also disappears when another message is showing. often doesn't reappear
;; (use-package minibuffer-line)

;; NOTE tried nick rougiers solution, works well, but also suffers from sleep and corfu-echo

;; LEFTOFF should use rougier's solution over mine, can still enable multi-line modeline, but should fix corfu issue and issue with keychord, maybe stop using keychord?

;;;; https://gist.github.com/rougier/096323d35ae3af5c8d0740dbb297f3e5
(provide 'echo-line)

(require 'subr-x)

(defun echo-line-format ()
  "String to be appended at right of echo area."
  (format-mode-line "%l:%c"))


(defun echo-line-message (orig-fun &rest args)
  "This enhanced message displays a regular message in the echo area
   and adds a specific text on the right part of the echo area. This
   is to be used as an advice."
  (let* ((right
          (concat
           ;; ! First space is a thin space, not a regular space
           ;; ! Last space needed to have truncated line
           " " (echo-line-format) " "
           ))
         (width (- (frame-width) (length right) 4))
         (msg (if (car args) (apply 'format-message args) ""))
         ;; Hack: The space for the split is a thin space, not a regular space
         ;; This way, we get rid of the added part if present (unless an actual
         ;; message uses a thin space.
         (msg (car (split-string msg " ")))
         (msg (string-trim msg))
         (left (truncate-string-to-width msg width nil nil "…"))
         (full (format (format "%%-%ds %%s" width) left right))
         )
    (if (active-minibuffer-window)
        ;; Regular log and display when minibuffer is active
        (apply orig-fun args)
      ;; Enhanced display
      (progn
        ;; Log actual message without echo
        (if message-log-max
            (let ((inhibit-message t)) (apply orig-fun (list msg))))
        ;; Display enhanced message without log
        (let ((message-truncate-lines t) (message-log-max nil))
          ;; (apply orig-fun (list full))
          (apply orig-fun (list (substring full 0 -1)))
         (set-display-table-slot
           (window-display-table (minibuffer-window))
           'truncation  (make-glyph-code (string-to-char (substring full -2))
                                         'default))
          )
        ;; Set current message explicitely
        (setq current-message msg)))))


;; Install advice
(advice-add 'message :around #'echo-line-message)

;; Instal post-command hook
(add-hook 'post-command-hook
          (lambda () (let ((message-log-max nil))
                       (message (current-message)))))
;; Install a display table in minibuffer window
(set-window-display-table (minibuffer-window) (make-display-table))
