;; -*- lexical-binding: t; -*-

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Core functions / utils
(defun z-soda-get-buffer-window (buf-name)
  (get-buffer-window (if (get-buffer buf-name)
                         (get-buffer buf-name)
                       (message "fooobar"))))

(defun z-soda-buffer-displayed-p (buf-name)
  (window-live-p (z-soda-get-buffer-window buf-name)))

(defun z-soda-delete (buf-name)           ;
  (interactive)
  (delete-window (z-soda-get-buffer-window buf-name)))

(defun z-soda-list-displaying-buffers ()
  "Lists the buffers that are being displayed in the current
frame.  This is done by looping through each displaying window
and storing the buf-or-mode-name of the buffer being sdisplayed in that
window to the buffer list that gets returned."
  (interactive)
  (let ((lst '()))
    (while (not (member (buffer-name (window-buffer)) lst))
      (setq lst (cons (buffer-name (window-buffer)) lst))
      (other-window 1))
    (butlast lst 0)))

(defun z-soda-sidewindow-p (buf)
  (if (window-parameter (get-buffer-window buf) 'window-slot)
      (message "yes")
    (message "no")))

(defun z-soda-list-displaying-side-windows ()
  (interactive)
  (let (
        (bufs (z-soda-list-displaying-buffers))
        )
    (when (member "yes" (mapcar 'z-soda-sidewindow-p bufs))
      (message "foo"))))

(defun z-soda-get-mode (buffer)
  (with-current-buffer buffer major-mode))

(defun z-soda-mode-displayed-p (mode)
  "Returns buf-name of buffer if a buffer with the major mode is
being displayed, otherwise returns nil"
  (let ((displaying-buffers (z-soda-list-displaying-buffers)))
    (-filter
     (lambda (buffer) (string-match mode (symbol-name (z-soda-get-mode buffer))))
     displaying-buffers)))

(defun z-soda-list-mode-buffers (mode)
  "Returns buf-name of buffer if a buffer with the major mode is
being displayed, otherwise returns nil"
  (let ((displaying-buffers (buffer-list)))
    (-filter
     (lambda (buffer) (string-match mode (symbol-name (z-soda-get-mode buffer))))
     displaying-buffers)))

(defun z-soda-mode-name (mode)
  (lambda (buffer &rest optional)
    (with-current-buffer buffer
      (string-match mode (symbol-name major-mode)))))


(defun z-soda-count-windows ()
  (setq lst '())
  (while (not (member (selected-window) lst))
    (setq lst (cons (selected-window) lst))
    (other-window 1))
  (length lst))












;;;;;;;;;;;; side windows
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Display buffer alist (leverages soda functions)
;; left top right bottom

(setq window-sides-slots '(3 3 3 4))
                                        ; ;tryign this ou for now
(setq window-sides-vertical t)

;; note you need to reevaluate the z-side function
(setq z-side-display-default-height-top 0.2)
(setq z-side-display-default-height-bottom 0.2)
(setq z-side-display-default-width-left 0.2)
(setq z-side-display-default-width-right 0.25)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; utils
;;; TODO change the order of the arguments for more settings like file
;;; (assuming these weren't split into each config)

;; this abstracts a little bit of code, but has a big impact as many
;; modes sould configure display settnigs, and there is currently no
;; great solution for doing that.

;; todo.. notion of a default side... almost like how popper assumes this...
;; todo.. allow for both height an width beinig displayed... should be
;; easy, just a another cond for if the second size parameter is
;; there, and if so, read int he height width order.
(defun z-side (regex &optional side slot size size2)
  ;; delete old config 
  (setq display-buffer-alist
        (-remove
         (lambda (elt) (cond ((stringp (nth 0 elt)) (string= (nth 0 elt) regex)) ;; remove this entry
                             ((equal (nth 0 elt) 'popper-display-control-p) nil) ;; keep this entry
                             ((equal (nth 0 elt) 'closure)
                               ;; parses out mode name used to create closure :-)
                              (equal (cdr (nth 0 (nth 1 (nth 0 elt)))) regex)) ;; remove this entry
                             (t nil)
                             ))
         display-buffer-alist)
        )

  ;; if side is top, set height to size
  (let (
        (height (cond
                 ((and size size2) size)
                 ((equal side 'top) (or size z-side-display-default-height-top))
                 ((equal side 'bottom) (or size z-side-display-default-height-bottom))
                 ((or (equal side 'left)
                      (equal side 'right))
                  nil)))
        (width (cond
                ((and size size2) size2)
                ((equal side 'left) (or size z-side-display-default-width-left))
                ((equal side 'right) (or size z-side-display-default-width-right))
                ((or (equal side 'top)
                     (equal side 'bottom))
                 nil)))
        (slot (or slot 0))
        )
    ;; update
    (add-to-list
     'display-buffer-alist
     (if (string-match "-mode$" regex)
         `(,(z-soda-mode-name regex)
           (display-buffer-in-side-window)
           (side . ,side) (slot . ,slot)
           (window-height . ,height) (window-width . ,width)
           (window-parameters . ((no-delete-other-windows . 1))))
       `(,regex
         (display-buffer-in-side-window)
         (side . ,side) (slot . ,slot)
         (window-height . ,height) (window-width . ,width)
         (window-parameters . ((no-delete-other-windows . 1))))
       )
     nil
     )
    )
  )



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Soda drink, cao, and switch to buffer
(defun z-soda-drink (func &optional buf-or-mode-name)
  (cond
   ;; displayed (by buffer name)
   ((z-soda-buffer-displayed-p buf-or-mode-name)
    (select-window (get-buffer-window buf-or-mode-name)))
   ;; displayed (by mode name)
   ((z-soda-mode-displayed-p buf-or-mode-name)
    (select-window (get-buffer-window (nth 0 (z-soda-mode-displayed-p buf-or-mode-name)))))
   ;; running, not displayed
   ((and (get-buffer buf-or-mode-name) (not (z-soda-buffer-displayed-p buf-or-mode-name)))
    (display-buffer buf-or-mode-name))

   ((not (get-buffer buf-or-mode-name))
    (funcall func buf-or-mode-name)))
  )

(defun z-soda-cap (target &optional mode-based)
  ;; what about closing based on mode?
  (interactive)
  (if mode-based
      ;; do a mode-based delete (should only be one window with that mode, based on how this tool is used)
      (let ((buf (nth 0 (z-soda-mode-displayed-p target))))
        (if buf
            (z-soda-delete buf)
          (message "Nothing like this is being displayed at the moment")))
    ;; otherwise, do a buffer-based delete
    (z-soda-delete target)))


;;(defun z-soda-switch-buffer ()
  ;;(interactive)
  ;;(let ((buffers (cond
                  ;;;; order matters here... I should eventually get better regexes
                  ;;((string-match "shell-mode" (symbol-name major-mode))
                   ;;(z-soda-list-mode-buffers "shell-mode"))
                  ;;((string-match "\\dired-mode*" (symbol-name major-mode))
                   ;;(z-soda-list-mode-buffers "\\dired-mode*"))
                  ;;((string-match "[H|h]elp*" (symbol-name major-mode))
                   ;;(z-soda-list-mode-buffers "[H|h]elp*"))
                  ;;((string-match "\\term-mode*" (symbol-name major-mode))
                   ;;(z-soda-list-mode-buffers "\\term-mode*"))
                  ;;)))
    ;;(if buffers
        ;;(switch-to-buffer
         ;;(completing-read
          ;;"Please select a buffer: "
          ;;(-map (lambda (x) (buffer-name x)) (delete (current-buffer) buffers))))
      ;;(ivy-switch-buffer)
      ;;)
    ;;))

(defun z-soda-create-and-display-messages (&optional buf-or-mode-name)
  (let ((buf (current-buffer)))
    (let ((newbuf (get-buffer-create "*Messages*")))
      (switch-to-buffer buf)
      (display-buffer newbuf)
      )
    )
  )

(defhydra+ hydra-run ()
  ("m" (lambda ()
         (interactive)
         (z-soda-drink (quote z-soda-create-and-display-messages) "*Messages*")
         ) "Messages")

  ("c" calendar "Calendar")
  ("i" info "Info")

  ("M" (lambda () (interactive) (z-soda-cap "*Messages*")) "Messages" )
  ("I" (lambda () (interactive) (z-soda-cap "*info*")) "Info")
  )

(general-define-key
 :keymaps 'evil-insert-state-map
 (general-chord ",r") 'hydra-run/body
 )

(general-define-key
 :states '(normal visual)
 :keymaps 'override
 :prefix ","
 "r" 'hydra-run/body
 )




(defalias 'use-package-handler/:display 'use-package-handle-forms)
(defalias 'use-package-normalize/:display 'use-package-normalize-forms)

(add-to-list 'use-package-keywords :display t)

(provide 'bootstrap-display)

