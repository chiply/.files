(use-package templatel)


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
  (cond
   ((string= program "async-shell-command") (zmc-es-async-shell-cmd cmd bufnm))
   ((string= program "vterm") (zmc-es-vterm cmd bufnm))
   ((string= program "compile") (zmc-es-compile cmd))
   (t (apply (intern program) `(,cmd)))))

(defun zmc-display-output-buffer (buf side slot)
  (display-buffer
   buf
   ;; todo, conditionally use side window.  can also make use
   ;; current buffer.  magneto can be used in that situation to
   ;; reposition the window
   `((display-buffer-in-side-window)
     (side . ,side)
     (slot . ,slot))))

(defun zmc-run (program cmd bufnm side slot select)
  (let* ((original-window (get-buffer-window (current-buffer) ))
         (new-buffer (zmc-execute program cmd bufnm)))
    (zmc-display-output-buffer new-buffer side slot)
    (select-window original-window)
    (when (string= "yes" select)
      (select-window (get-buffer-window new-buffer)))))

(defun zmc-es-compile (cmd)
  ;; LEFT OFF how to solve this... combine with latest?  
  ;; this still isn't ideal as switching buffers would cause the
  ;; buffername to change to something generic again
  ;; also note this is distinct from command
  ;; there should be a 'latest buffername function'
  (let ((compilation-buffer-name-function '(lambda (_)
                                             (or (when (boundp 'local-transient) local-transient) latest-transient)))
        (compile-command (or local-cmd latest-cmd))
        )
    (save-window-excursion (compile compile-command))
    )
  )

(defun zmc-es-recompile ()
  ;; LEFT OFF how to solve this... combine with latest?  
  ;; this still isn't ideal as switching buffers would cause the
  ;; buffername to change to something generic again
  ;; also note this is distinct from command
  ;; there should be a 'latest buffername function'
  (interactive)
  (let ((compilation-buffer-name-function '(lambda (_)
                                             (or (when (boundp 'local-transient) local-transient) latest-transient)))
        (compile-command (or local-cmd latest-cmd))
        )
    (save-window-excursion (recompile))
    ))


(defun zmc-es-async-shell-cmd (cmd bufnm)
  (let ((bufnm (or (when (boundp 'local-transient) local-transient) latest-transient)))
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
   (list (transient-args (intern (or (when (boundp 'local-transient) local-transient) latest-transient)))))
  (let* (;; hashtbl
         (target (zmc-get-hashtbl args))
         (program (ht-get target "program"))
         ;; NYI: exiting the transient with an action will override the
         ;; associated settings in the hashtable as so they will get picked
         ;; up by downstream processing... includes 
         (command-template (ht-get target "template"))
        ;;; feature complex jinja-like template rendering via templatel
         (cmd (templatel-render-string command-template (ht->alist target)))
         (_ (ht-set! target "target" cmd))
         (directory (ht-get target "directory"))
         (default-directory (or (and
                                 directory
                                 (expand-file-name (eval-expression directory)))
                                default-directory))
         (bufnm (ht-get target "bufnm"))
         (side (intern (or (ht-get target "side") "top")))
         (slot (or (ht-get target "slot") 1))
         (select (or (ht-get target "select") "no"))
         ;; feature NYI: configuration can point to a specific
         ;; transient as a settings menu
         ;; note: this is needed since dir locals don't get activated
         ;; when calling globally, you need to actually be in that
         ;; directory.  works with relative dirs, so this can be
         ;; relative to value in dir:
         ;;(_ (let ((venv (ht-get target "virtual-environment"))) (and
         ;;venv (pyvenv-activate venv))))
         )
    (setq latest-cmd cmd)
    (set (make-local-variable 'local-cmd) cmd)
    (message "foobar")
    (message cmd)

    (apply 'zmc-run `(,program ,cmd ,bufnm ,side ,slot ,select))
    )
  )

;;;;;;;;;;;;;;;;;;;;;; TRANSIENT
(defun zmc-define-transient (name htbl)
  (eval
   `(transient-define-prefix ,(intern name) ()
      ;; populate initial default arguments from the config
      ;; note!  this only gets defined once, so these default values
      ;; can be effectively overwritten by saving the transient's
      ;; state
      :value (quote
              ,(ht-map (lambda (k v)
                         (concat "--" (string-replace " " "-" k) "=" v))
                       htbl))
      ;; Arguments
      ,(vconcat
        (vector "Arguments")
        (apply 'vector (ht-map
                        (lambda (k v)
                          `(;; NYI -- unique-ifies
                            ,(concat "-" (substring k 0 1))
                            ,k
                            ,(concat "--" (string-replace " " "-" k) "=")
                                        ;:reader
                            ;;; feature NYI: selects reader based 1) whether
                            ;;; the key is a keyword key or 2) whether
                            ;;; the key has a type, which implies a
                            ;;; prompter and a validator
                                        ;(lambda (prompt _initial_input history)
                              ;;; TODO setup cond.. if a keyword then map to completer
                              ;;; if k is a 2 tuple, then the second string is type
                                        ;(completing-read prompt '(foo bar))
                              ;;; (validation)
                                        ;)
                            ))
                        htbl)))
      ;; Actions
      [;; Action should simply take arguments and override variables
       ;; in the hashtable
       "Actions"
       ("<return>" "run" zmc-transient-act)
       ]
      )))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; INTERACTIVE FUNCTION

;; prefix arg
(defun zmc (&optional arg)
  "Choice target and start compile."
  (interactive "P")
  (cond
   ((and arg (boundp 'local-transient))
    (progn
      (message "local")
      (setq latest-transient local-transient)
      (funcall (intern local-transient))
      (execute-kbd-macro (kbd "<return>"))
      ))
   ((and arg latest-transient)
    (progn
      (message "latest")
      (setq-local local-transient latest-transient) ;; TODO do we want ot set this?
      (funcall (intern latest-transient))
      (execute-kbd-macro (kbd "<return>"))
      ))
   (t
    (let* (;; feature: read from yaml
           (config-raw (with-temp-buffer
                         (insert-file-contents "~/.cmds.yaml")
                         (buffer-string)))
           (targets (yaml-parse-string
                     ;; feature NYI: union cmds defined in homedir and
                     ;; local context, eg project's home directory
                     config-raw
                     :object-key-type 'string))
           ;; feature NYI: optional narrow wrt on predicates evald @ runtime
           (target-keys (ht-keys (ht-select (lambda (k v) (if t t (eval (ht-get v "if")))) targets)))
           ;; feature NYI: selection of multiple targets
           (key (completing-read "target " target-keys)) ; needed to pass key into target object
        ;;; adding key name to targte object for convenient packaging
        ;;; feature, prepoerties of uniqueness make this value a good
        ;;; candidate for default values like buffer-name
           (target (ht-get targets key)) ; the hash table representing the cmd and its attributes
           (_ (ht-set! target "key" key))
           ;; feature: complex settings with rich interface for settings based on type
           (transient-name (string-replace " " "-" key))
           ;; feature NYI: optinally override settings in the hashtable
           ;; at runtime w transient.. transient will have the effect of
           ;; adding or modifying keys in target
           ;; feature NYI: calls transient if exists (to benefti from getting
           ;; history), otherwise creates.  Can force recereation,
           ;; althugh use case for this is rare (eg when editing .cmds.yaml)

           ;; due to the fact that I can't halt execution at the
           ;; transient (hydra suffers from this as well) the transient
           ;; needs to build the rest of the function as the action
           ;; can we define the action function dynamically? try w message
           ;; frsutrating issue since it forces me to break this up further
           (_ (zmc-define-transient transient-name target)) ; define the transient
           )
      ;; sets the name of the transient currently being used
      ;; transient act uses this to determine what the arms are)
      (setq latest-transient transient-name) ;; global
      (set (make-local-variable 'local-transient) transient-name) ;; local
      (funcall (intern transient-name))
      ))
   )
  )

;; todo -- need to place more option inside the transient
;; this way we can leverage the saving mechanism
;; but first, we can go for a quick implementation but simply not using recompile (and therefore havign to make sure we're 'saving' settings, just write my own recompiile function that basically re-runs zmc, but without prompting for the command... just not sure how to call transientw ithout proptin

;; maybe don't need to make any modifications outside of simply making another command for recompile;; also can abstract recompile, this may require the create / replace commands though.

(general-define-key
 :states '(normal visual emacs insert)
 :keymaps '(override)
 "s-<return>" 'zmc
 "s-r" '(lambda () (interactive)
          (setq current-prefix-arg '(4))
          (call-interactively 'zmc))
 )

