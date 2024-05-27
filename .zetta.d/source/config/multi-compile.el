(use-package templatel)

;; better version of multi-compile that has better support from embark
;; and consult and also offers parsing of build system targets (eg
;; makefile targets).  Integrate automatic pulling of targets with
;; this project.
;; NOTE can't get all the icons or consult working

;; TODO probably don't need to demand these
(use-package compile-multi :demand t)
(use-package consult-compile-multi :demand t :config (consult-compile-multi-mode))
(use-package all-the-icons-completion
  :demand t
  :config
  (all-the-icons-completion-mode)
  (add-hook 'marginalia-mode-hook #'all-the-icons-completion-marginalia-setup))

(use-package compile-multi-all-the-icons :demand t)

(use-package compile-multi-embark :demand t :config (compile-multi-embark-mode +1))
(use-package projection :demand t)
(use-package projection-multi :demand t)
(use-package projection-multi-embark :demand t)

(require 'projection-multi-make)

;; TODO
;; cleanup
;; display buffer function
;; replacement logic -- lay out all the different use casces and options
;;;; *replace* eg kill original,
;;;; *display* original,
;;;; *switch* to original (display and select),
;;;; *create* with new buffername (simply prompt with what would have been used)
;; DONE select v noselect
;; refactor how bufnm is being set
;; some indication as to what mode the buffer is in in the modeline

;;;;;;;;;;;;;;;;;; HELPERS
(defun zmc-get-hashtbl (args)
  (ht<-alist
   (-map
    (lambda (e)
      (let* ((kv (split-string e "="))
             (k (string-replace "--" "" (car kv)))
             (v (string-join (cdr kv) "=")))
        `(,k . ,v)))
    args)))

;;;;;;;;;;;;;;;;;;;;;; EXECUTORS
;; boudned complexity: 3 main strategies: compile,
;; async-shell-command, and vterm.  Each of these has a detached
;; variant
(defun zmc-execute (program cmd bufnm)
  (let ((shell-command-switch "-ic"))
    (cond
     ((string= program "async-shell-command") (zmc-es-async-shell-cmd cmd bufnm))
     ((string= program "vterm") (zmc-es-vterm cmd bufnm))
     ((string= program "compile") (zmc-es-compile cmd))
     (t (apply (intern program) `(,cmd))))))


(defun zmc-run (program cmd bufnm side slot select)
  (let* ((original-window (get-buffer-window (current-buffer) ))
         (new-buffer (zmc-execute program cmd bufnm)))

    (display-buffer new-buffer)

    (select-window original-window)
    (when (string= "yes" select)
      (select-window (get-buffer-window new-buffer)))))

(defun zmc-es-compile (cmd)
  (let ((compilation-buffer-name-function
         '(lambda (_)
            (or (when (boundp 'local-transient)
                  local-transient)
                latest-transient)))
        (compile-command (or local-cmd latest-cmd)))
    (save-window-excursion (compile compile-command))))

(defun zmc-es-recompile ()
  ;; LEFT OFF how to solve this... combine with latest?  
  ;; this still isn't ideal as switching buffers would cause the
  ;; buffername to change to something generic again
  ;; also note this is distinct from command
  ;; there should be a 'latest buffername function'
  (interactive)
  (let ((compilation-buffer-name-function
         '(lambda (_)
            (or (when (boundp 'local-transient) local-transient)
                latest-transient)))
        (compile-command (or local-cmd latest-cmd)))
    (save-window-excursion (recompile))))


(defun zmc-es-async-shell-cmd (cmd bufnm)
  (let ((bufnm (or (when (boundp 'local-transient) local-transient) latest-transient))
        (process-connection-type nil))
    (save-window-excursion
      (window-buffer (async-shell-command cmd bufnm)))))

(defun zmc-es-vterm (cmd bufnm)
  ;; if bufnm exists kill it
  (let* ((bufnm (or (when (boundp 'local-transient) local-transient) latest-transient)))
    ;; todo make this configurable, should it kill, switch to it,
    ;; create new with uniquify name, prompt for name? prompt for any
    ;; of these options?
    (when (get-buffer bufnm)
      (kill-buffer bufnm))
    ;; todo -- would save window excursion work here?
    (let* ((vterm-buffer (save-window-excursion (vterm bufnm)))
           (vterm-process (get-buffer-process vterm-buffer)))
      (process-send-string vterm-process (concat cmd "\n"))
      bufnm)))

;;;;;;;;;;;;;;;;;;;;;; ACTION
(defun zmc-transient-act (&optional args)
  (interactive
   (list (transient-args
          (intern (or
                   (when (boundp 'local-transient)
                     local-transient)
                   latest-transient)))))
  (let* ((target (zmc-get-hashtbl args))
         (program (ht-get target "program"))
         (command-template (ht-get target "template"))
         (cmd (templatel-render-string command-template (ht->alist target)))
         (_ (ht-set! target "target" cmd))
         (directory (ht-get target "directory"))
         (default-directory (or (and
                                 directory
                                 (expand-file-name (eval-expression directory)))
                                default-directory))
         (bufnm (ht-get target "bufnm"))
         (side (intern (or (ht-get target "side") "top"))) ;; default
         (slot (or (ht-get target "slot") 1)) ;; default
         (select (or (ht-get target "select") "no")))
    (setq latest-cmd cmd)
    (set (make-local-variable 'local-cmd) cmd)
    (apply 'zmc-run `(,program ,cmd ,bufnm ,side ,slot ,select))))


;;;;;;;;;;;;;;;;;;;;;; TRANSIENT
(defun zmc-define-transient (name htbl)
  (eval
   `(transient-define-prefix ,(intern name) ()
      ;; populate initial default arguments from the config
      ;; note!  this only gets defined once, so these default values
      ;; can be effectively overwritten by saving the transient's
      ;; state
      :value
      (quote
       ,(ht-map (lambda (k v) (concat "--" (string-replace " " "-" k) "=" v)) htbl))
      ;; Arguments
      ,(vconcat
        (vector "Arguments")
        (apply
         'vector
         (ht-map
          (lambda (k v)
            `(,(concat "-" (substring k 0 1)) ,k ,(concat "--" (string-replace " " "-" k) "=")))
          htbl)))
      ;; Actions
      [;; Action should simply take arguments and override variables
       "Actions"
       ("<return>" "run" zmc-transient-act)
       ]
      )))

(defun zmc-detect-targets ()
  (eval
   (append
    '(ht-merge)
    (-filter
     (lambda (x) x)
     (-map
      (lambda (project-path)
        ;; todo -- need to handle multiple build files in the same directory / same project
        ;; basically add a for loop iterating through types. support this only when needed
        (let ((build-file-name
               (cond
                ((file-exists-p (concat project-path "makefile")) "makefile")
                ((file-exists-p (concat project-path "Makefile")) "Makefile"))))
          (when build-file-name
            (ht-from-alist
             (-map
              (lambda (target)
                `(,(concat
                    (file-name-nondirectory
                     (directory-file-name project-path))
                    "--" target)
                  .
                  ,(ht-from-alist
                    `(("template" . ,(concat "make " target))
                      ("directory" . ,project-path)
                      ("program" . "compile")))))
              (projection-multi-make--targets-from-file2
               (concat project-path build-file-name)))))))
      projectile-known-projects)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; INTERACTIVE FUNCTION
(defun zmc (&optional arg)
  "Choice target and start compile."
  (interactive "P")
  ;; call recent transient if it exists
  (cond
   ((and arg (boundp 'local-transient))
    (progn
      (setq latest-transient local-transient)
      (funcall (intern local-transient))
      (unless (equal arg '(16))
        (execute-kbd-macro (kbd "<return>")))))
   ((and arg latest-transient)
    (progn
      (setq-local local-transient latest-transient)
      (funcall (intern latest-transient))
      (unless (equal arg '(16))
        (execute-kbd-macro (kbd "<return>")))))
   (t (let* ((detected-targets (zmc-detect-targets))
             (config-raw (with-temp-buffer (insert-file-contents "~/.cmds.yaml") (buffer-string)))
             (targets (yaml-parse-string config-raw :object-key-type 'string))
             (targets (ht-merge detected-targets targets))
             (target-keys (ht-keys (ht-select
                                    (lambda (k v) (if t t (eval (ht-get v "if"))))
                                    targets)))
             (key (completing-read "target " target-keys)) ; needed to pass key into target object
             (target (ht-get targets key)) ; the hash table representing the cmd and its attributes
             (_ (ht-set! target "key" key))
             (transient-name (string-replace " " "-" key))
             ;; feature NYI: calls transient if exists (to benefti from getting
             ;; history), otherwise creates.  Can force recereation,
             ;; althugh use case for this is rare (eg when editing .cmds.yaml)
             (_ (zmc-define-transient transient-name target)) ; define the transient
             )
        ;; sets the name of the transient currently being used
        ;; transient act uses this to determine what the arms are)
        (setq latest-transient transient-name) ;; global
        (set (make-local-variable 'local-transient) transient-name) ;; local
        (funcall (intern transient-name))))))


(general-define-key
 ;; override alone doesn't work...
 :keymaps (append z-modal-states-insert z-modal-states-non-insert '(override))
 "s-<return>" 'zmc
 "s-r" '(lambda () (interactive)
          (setq current-prefix-arg '(4))
          (call-interactively 'zmc))
 "s-R" '(lambda () (interactive)
          (setq current-prefix-arg '(16))
          (call-interactively 'zmc)))
