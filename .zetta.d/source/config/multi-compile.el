(use-package templatel)

;; start to create a todo list and a plan to adopt.  for example,
;; things like transient layouts, hidden parameters, etc... can wait,
;; need to prioritize

;; can start pre-emptivley refactoring things out as i create my tasks

;; left off -- type and completers are likley next most important
;; put some critical thought into the design of that -- what patterns will be used
;; eg one stratefy (eg function) per type?

;; test that the template works...  try this out with make unit_test
;; in tx;; just make {{ x_foo }} one of the variables.. note the
;; design will need some way to signal to the end user that a key word
;; is being use

;; invisible data -- eg key, command template, etc...

;; general note -- this isn't a great way of doing things, the eval is
;; making things slow to develop
(defun z-dynamic-transient (name htbl)
  (eval
   `(transient-define-prefix ,(intern name) ()
      ;; populate initial default arguments from the config
      ;; note!  this only gets defined once, so these default values
      ;; can be effectively overwritten by saving the transient's
      ;; state
      :value (quote
              ,(ht-map
                (lambda (k v)
                  (concat "--"
                          (string-replace " " "-" k)
                          "=" v))
                htbl))
      ;; Arguments
      ,(vconcat
        (vector "Arguments")
        (apply 'vector (ht-map
                        (lambda (k v)
                          `(
                            ;; NYI -- unique-ifies
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
      [
       ;; Action should simply take arguments and override variables
       ;; in the hashtable
       "Actions"
       ;; left off can keep like this
       ("<return>" "run" z-multi-compile-transient-act)
       ]
      )
   )
  )

;; function builds and invokes transient
(defun z-multi-compile-run ()
  "Choice target and start compile."
  (interactive)
  (let* (
         ;; feature: read from yaml
         (config-raw (with-temp-buffer
                       (insert-file-contents "~/.cmds.yaml")
                       (buffer-string)))
         (targets (yaml-parse-string
                   ;; feature NYI: union cmds defined in homedir and
                   ;; local context, eg project's home directory
                   config-raw
                   :object-key-type 'string))
         (target-keys (ht-keys
                       ;; feature NYI: optional narrow wrt on predicates evald @ runtime
                       (ht-select (lambda (k v) (if t t (eval (ht-get v "if")))) targets)))
         ;; feature NYI: selection of multiple targets
         (key (completing-read "target " target-keys)) ; needed to pass key into target object
        ;;; adding key name to targte object for convenient packaging
        ;;; feature, prepoerties of uniqueness make this value a good
        ;;; candidate for default values like buffer-name
         (target (ht-get targets key)) ; the hash table representing the command and its attributes
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
         (_ (z-dynamic-transient transient-name target)) ; define the transient
         )
    ;; sets the name of the transient currently being used
    ;; transient act uses this to determine what the arms are)
    (setq z-current-transient transient-name)
    (funcall (intern transient-name))
    )
  )

(defun z-multi-compile-transient-act (&optional args)
  (interactive
   (list (transient-args (intern z-current-transient))))
  (let* (
         ;; hastbl
         (target (ht<-alist
                  (-map
                   (lambda (e)
                     (let* ((kv (split-string e "="))
                            (k (string-replace "--" "" (nth 0 kv)))
                            (v (nth 1 kv)))
                       `(,k . ,v)))
                   args)))
         (program (ht-get target "program"))
         ;; NYI: exiting the transient with an action will override the
         ;; associated settings in the hashtable as so they will get picked
         ;; up by downstream processing... includes 
         (command-template (ht-get target "template"))
        ;;; feature complex jinja-like template rendering via templatel
         (command (templatel-render-string command-template (ht->alist target)))
         (_ (ht-set! target "target" command))
         (directory (ht-get target "directory"))
         (default-directory (or (and directory (expand-file-name (eval-expression directory)))
                                default-directory))

         ;; feature NYI: configuration can point to a specific
         ;; transient as a settings menu
         ;; note: this is needed since dir locals don't get activated
         ;; when calling globally, you need to actually be in that
         ;; directory.  works with relative dirs, so this can be
         ;; relative to value in dir:
         ;;(_ (let ((venv (ht-get target "virtual-environment"))) (and venv (pyvenv-activate venv))))
         )
    (apply (intern program) `(,command))
    )
  )



;;(z-multi-compile-run)



;; todo -- do we need to build the transient with a new name each
;; time?  Yes -- this helps manage data, eg state per transient

;; BIG FEATURES:
;;;; variables in configuration (as top level keys? yes and specify data type for everything)  the type of each key will actually point to a function that will specify the validation and prompt strategies
;;;; variables overrideable from transient based on datatype (just use 2 datatypes)
;;;; transient is built dynamically from variables and top level settings being merged.  transient shoudl basically allow any key in the ht to be replaced... keep the ht flat!
;;;; transient to override template variables
;;;; transient to override general settings (eg venv, program, etc...)
;;;; keyword template variables similar to how multi-compile works
;; syntax extension: variable references in the configuration to increase brevity
;; jsonschema based utils -- eg snippet for creating a new target in cmds


;; TODO:
;;;; bring in any features from foreman into this spec
;;;; DONE fully strip away multi compile (will involve setting this up in 
;;;; the same way foreman is)
;; other settings: display postiion




;; Just an interest in general not about what's happening here. The continent of each top level key income is not Llamo is effectively and end-users description of how that command is used. This is actually what is getting used in Lou of a actual schema or usable man fileThat could be used to automate the production of transients. So the configuration is both a registry of commands, but it's also the data that's being used by the automatic transient production solution. It's going to be important as this gets built out to ensure that all the flexibility needed in the transient can be controlled by adding things to the come on start Yami.  Otherwise this won't be truly configuration driven, and adding functionality for let's say a new set of command line commands would be required changes to the code which is undesirable.  

;; NYI maintaining a history of compile commands at the buffer level
;; at different levels -- project?  for example, in foreman, there was
;; a compule command bound to each buffer


;; LEFT OFF:
;;;; dynamically build transient
;;;; why do i have to specify the env in the case of makefile being present? try to fix this


;;(progn
;;  (with-local-quit (hydra-window/body))
;;  (message "gello")
;;  )








;;(z-compile)

