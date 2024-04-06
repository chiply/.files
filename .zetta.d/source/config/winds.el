(use-package winds
  :custom
  (winds-default-ws 1)
  (winds-default-cfg 1)
  (with-eval-after-load 'desktop (winds-enable-desktop-save))
  :init
  ;; Avoid lazy loading so that history is saved
  ;; from the very start of session
  (winds-mode)
  (winds-history-mode)
  (setq z-ws-alist '(("main" . 1)))
  (add-to-list 'desktop-globals-to-save 'z-ws-alist)

  :config
  (setq winds-init-cfg-hook
        (list (lambda (w c)
                (ignore w c)
                (when (z-soda-list-displaying-side-windows)
                  (window-toggle-side-windows))
                (delete-other-windows)
                (switch-to-buffer "*scratch*")
                ;; left off -- need naming convention to uniquify the bvs
                ;; save default bookmark (unique name for ws cfg) and add to z-ws-cfg-bv-list
                (z-ws-cfg-bv-new-bv "default") 
                )))

  (defun z-modify-ws-alist (action name id &optional newname)
    (let* ((alst z-ws-alist)
           (newalst (cond ((string= action "-") (delq (assoc name alst) alst))
                          ((string= action "+") (append `((,name . ,id)) alst))
                          ((string= action "^") (let ((l1 (delq (assoc name alst) alst)))
                                                  (if (assoc name alst)
                                                      (append `((,newname . ,id)) l1)
                                                    alst))))))
      (delete-dups newalst)))

  (defun winds-extra-goto-ws (&optional name)
    (interactive)
    "A wrapper for winds-goto, specifically for ws, that updates z-ws-alist"
    (winds-extra-record-ws-cfg-bv-leftoff)
    (let* ((name (or name (completing-read "Select a ws: " z-ws-alist)))
           (id (if (member name (-map (lambda (x) (car x)) z-ws-alist))
                   (cdr (assoc name z-ws-alist))
                 (+ 1 (seq-max (winds--get-wsids))))))
      (setq z-ws-alist (z-modify-ws-alist "+" name id))
      (winds-goto :ws id))
    (winds-extra-set-ws-cfg-bv))

  (defun winds-extra-delete-ws ()
    (interactive)
    "A wrapper for winds-close, specifically for ws, that updates z-ws-alist"
    (let ((name (car (car z-ws-alist)))
          (id (cdr (car z-ws-alist))))
      (setq z-ws-alist (z-modify-ws-alist "-" name id))
      (winds-close id)))

  (defun winds-extra-rename-ws ()
    (interactive)
    "Renames the current ws"
    (let ((name (car (car z-ws-alist)))
          (id (cdr (car z-ws-alist)))
          (newname (read-minibuffer "Please enter a new ws name: ")))
      (setq z-ws-alist (z-modify-ws-alist "^" name id newname))))

  (defun winds-extra-switch-to-last-ws ()
    (interactive)
    "A wrapper for winds-goto, specifically for ws, that switches
to the previously select ws and updates z-ws-alist"
    (winds-extra-record-ws-cfg-bv-leftoff)
    (let ((name (car (nth 1 z-ws-alist)))
          (id (cdr (nth 1 z-ws-alist))))
      (if (member name (-map (lambda (x) (car x)) z-ws-alist))
          (progn
            (winds-goto :ws id)
            (setq z-ws-alist (z-modify-ws-alist "+" name id))
            (winds-extra-set-ws-cfg-bv))
        (message "ws doesn't exist")))
    )

  (defun winds-extra-record-ws-cfg-bv-leftoff ()
    ;; record the last bv for tthe ws-cfg
    (setf
     (alist-get
      `(,(intern (car (car z-ws-alist))) ,(winds-get-cur-cfg))
      z-ws-cfg-bv-leftoff
      nil nil 'equal)
     z-ws-cfg-bv-current-bv
     )
    )

  (defun winds-extra-set-ws-cfg-bv ()
    (setq z-ws-cfg-bv-current-bv
          (or
           ;; when it already exists
           (alist-get
            `(,(intern (car (car z-ws-alist))) ,(winds-get-cur-cfg))
            z-ws-cfg-bv-leftoff
            nil nil 'equal)
           ;; when it's just been created (eg it has never been left off)
           (concat
            "bv--"
            (car (car z-ws-alist))
            "-"
            (number-to-string (winds-get-cur-cfg))
            (format ": %s" "default")))))

  (defun winds-extra-goto (&keys cfg)
    (winds-extra-record-ws-cfg-bv-leftoff)
    (winds-goto :cfg cfg)
    (winds-extra-set-ws-cfg-bv))

  ;;:general
  ;;(
   ;;:keymaps '(override)
   ;;"s-a" (lambda () (interactive) (winds-extra-goto :cfg 1))
   ;;"s-s" (lambda () (interactive) (winds-extra-goto :cfg 2))
   ;;"s-d" (lambda () (interactive) (winds-extra-goto :cfg 3))
   ;;"s-f" (lambda () (interactive) (winds-extra-goto :cfg 4))
   ;;"s-g" (lambda () (interactive) (winds-extra-goto :cfg 5))
   ;;"M-S-<tab>" 'winds-extra-goto-ws
   ;;"M-<tab>" 'winds-extra-switch-to-last-ws
   ;;)
;;
  ;;:hydra
  ;;(defhydra+ hydra-window ()
    ;;("u" winds-history-undo) 
    ;;("U" winds-history-redo)
    ;;("C-d" winds-extra-delete-ws :exit t)
    ;;("C-r" winds-extra-rename-ws :exit t)
    ;;)
  )
