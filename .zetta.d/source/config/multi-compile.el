;; TODO LEFT OFF -- pytest is very slow to pull targets, but does its probably
;; being called wastefully -- probably need to refactor all these

;; TODO make detached-shell command ebhave liek async shell command
;; wrt to uniquifying buffer name.  don't uniquify unless can make
;; this work with sentinels

;; better version of multi-compile that has better support from embark
;; and consult and also offers parsing of build system targets (eg
;; makefile targets).  Integrate automatic pulling of targets with
;; this project.
;; NOTE can't get all the icons or consult working

;; TODO
;; cleanup
;; display buffer function
;; replacement logic -- lay out all the different use casces and options
;; update: I'm going to call this a replace-buffer-function as this is operating at the buffer name level... 
;;;; *replace* eg kill original,
;;;; *switch* to original (display and select),
;;;; *display* to original (display and don't select),
;;;; *create* with new buffername (simply prompt with what would have been used, eg provide a randomized thing as default)
;;;; *warn* 
;;;; *default-buffer-replace-policy* to ease the change, implement a policy that does default-buffer-replace-policy (currently there is not really a policy, it just does default-buffer-replace-policy). note this would default to the underlying executor's default behavior.  eg for async-shell-command, it would simply warn you that the buffer already exists and do default-buffer-replace-policy.  I would typically prefer to set things explicitly
;; DONE select v noselect
;; refactor how bufnm is being set
;; some indication as to what mode the buffer is in in the modeline


;;;;;;;;;;;;;;;; DEPENDENCIES
(use-package templatel)
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


;; LEFT OFF - grow phase, organize todos and need to refactor
;; TODO refactoring -- funcctionalty wrt (zmc-compute-bufnm), headerline stuff, transient name.  should be consolidated... probably already is (derived from key) so should be easy to solve
;; todo add custom buffer names
;; TODO side key not working for vterm -- using magento in mid term


;; TODO - timing of setting local and latest-transient -- should only happen once the transient has been executed, but this may be challenging or require more refactoring

;; VARIABLES
(setq zmc-async-shell-command-spinners-enable nil)

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

(defun zmc-compute-bufnm ()
  (or (when (boundp 'local-transient) local-transient) latest-transient))

;;;;;;;;;;;;;;;;;; Enhanced versions of async-shell-command and
;;;;;;;;;;;;;;;;;; detached-shell-command
(defun zmc-command-sentinel (process signal)
  "`zmc-async-shell-command+` is an async/compile variant allowing to
leverage the high speed features of async-shell-command with the
convenient error parsing and ergonomics of compilation-mode.
Also includes mechanisms for notifications, spinners, and
annotation of output (via highlight phrases).  This functions use
of process sentinel should serve as a reference implementation
for doing this with any other subprocess-creating function like
async-shell-command"
  (let* ((buf (process-buffer process))
         (bufnm (buffer-name buf)))
    (when (memq (process-status process) '(exit signal))
      (with-current-buffer buf
        (compilation-minor-mode t)
        (z-compile-spin-stop buf signal)
        (z-highlight-phrases)
        (alert (concat bufnm " exited with signal: " signal)
               :title "zmc finished"))
      (shell-command-sentinel process signal))))


(defun zmc-async-shell-command+ (command output-buffer &optional error-buffer)
  (let* ((proc (progn
                 (async-shell-command command output-buffer error-buffer)
                 (with-current-buffer output-buffer
                   (z-highlight-phrases))
                 (get-buffer-process output-buffer))))
    (if (process-live-p proc)
        (progn
          (set-process-sentinel proc #'zmc-command-sentinel)
          output-buffer)
      (message "No process running"))))


(defun zmc-detached-shell-command+ (command output-buffer)
  (let* ((detached--shell-command-buffer output-buffer)
         (proc (progn
                 (detached-shell-command command)
                 (with-current-buffer output-buffer
                   (z-highlight-phrases))
                 (get-buffer-process output-buffer))))
    (if (process-live-p proc)
        (progn
          (set-process-sentinel proc #'zmc-command-sentinel)
          output-buffer)
      (message "No process running"))))


;;;;;;;;;;;;;;;;;;;;;; EXECUTORS
(setq default-buffer-replace-policy "default-buffer-replace-policy") ;; TODO keep an eye on this - may cause issues
(defun zmc-execute (program cmd bufnm &optional buffer-replace-policy transient-name)
  (if (not (member
            program
            '("detached" "detached+" "async-shell-command"
              "async-shell-command+" "vterm" "compile"
              "detached-compile")))
      (error "zmc-execute: program %s not supported" program))
  (let ((bufnm (zmc-compute-bufnm))
        (buffer-replace-policy (or buffer-replace-policy default-buffer-replace-policy)))
    (cond ((string= buffer-replace-policy "replace")
           (when (get-buffer bufnm)
             ;; kill the process associated with the buffer
             (let ((proc (get-buffer-process bufnm)))
               (when (process-live-p proc)
                 (progn
                   (kill-process proc)
                   (let ((timeout 2)
                         (start-time (current-time)))
                     (while (and (process-live-p proc)
                                 (< (time-to-seconds (time-since start-time))
                                    timeout))
                       (sleep-for 0.05))))))))
          ((string= buffer-replace-policy "switch")
           (when (get-buffer bufnm)
             (switch-to-buffer bufnm)))
          ((string= buffer-replace-policy "display")
           (when (get-buffer bufnm)
             (display-buffer bufnm)))
          ((string= buffer-replace-policy "create")
           (when (get-buffer bufnm)
             (let ((bufnm (generate-new-buffer-name bufnm)))
               (display-buffer bufnm))))
          ((string= buffer-replace-policy "warn")
           (when (get-buffer bufnm)
             (message "Buffer %s already exists" bufnm)))
          ((string= buffer-replace-policy "default-buffer-replace-policy")
           (message "no replacing"))
          (t (message "Buffer %s already exists" bufnm))))

  (let* ((shell-command-switch "-ic")
         (buf (cond
               ((string= program "detached") (zmc-es-detached cmd))
               ((string= program "detached+") (zmc-es-detached+ cmd))
               ((string= program "async-shell-command") (zmc-es-async-shell-command cmd))
               ((string= program "async-shell-command+") (zmc-es-async-shell-command+ cmd))
               ((string= program "vterm") (zmc-es-vterm cmd))
               ((string= program "compile") (zmc-es-compile cmd))
               ((string= program "detached-compile") (zmc-es-detached-compile cmd)))))
    (save-window-excursion
      (switch-to-buffer buf)
      (set (make-local-variable 'local-transient) transient-name))
    (if (or (bufferp buf) (bufferp (get-buffer buf)))
        buf
      (error "zmc-execute: executor did not return a buffer"))
    ))

(defun zmc-run (program cmd bufnm side slot select &optional buffer-replace-policy transient-name)
  (let* ((original-buffer (current-buffer))
         (original-window (get-buffer-window original-buffer))
         (new-buffer (zmc-execute program cmd bufnm buffer-replace-policy transient-name)))
    (unless (string= (buffer-name original-buffer)
                     (cond
                      ((bufferp new-buffer)
                         (buffer-name new-buffer))
                      ;; case it is a string
                      ((stringp new-buffer) new-buffer)))
      ;; removes from the current window's tab list, this has the impact
      ;; of avoiding polluting the tab list of the buffer from which zmc
      ;; is called with potentially unnecessary tabs pointing to the
      ;; created buffer
      (switch-to-buffer new-buffer)
      ;; got this part from bury-buffer function
      (set-window-dedicated-p nil nil)
      (switch-to-prev-buffer nil 'bury)
      ;; display the buffer.  The point here is that
      ;; display-buffer-alist settings are resepected by default but
      ;; these can also be overridden by the user NYI TODO implement
      ;; overrideable display
      (display-buffer new-buffer)
      (select-window original-window)
      )
    (when (string= "yes" select)
      (select-window (get-buffer-window new-buffer)))))


;; individual executors
(defun zmc-es-compile (cmd)
  (let ((compilation-buffer-name-function '(lambda (_) (zmc-compute-bufnm)))
        (compile-command (or local-cmd latest-cmd)))
    (save-window-excursion (compile compile-command))))

(defun zmc-es-detached-compile (cmd)
  (let ((compilation-buffer-name-function '(lambda (_) (zmc-compute-bufnm)))
        (compile-command (or local-cmd latest-cmd)))
    (save-window-excursion (detached-compile compile-command))))

(defun zmc-es-async-shell-command (cmd)
  (let ((bufnm (zmc-compute-bufnm))
        (process-connection-type nil) ;; performance
        )
    (save-window-excursion
      (window-buffer (async-shell-command cmd bufnm)))))

(defun zmc-es-async-shell-command+ (cmd)
  (let ((bufnm (zmc-compute-bufnm))
        (process-connection-type nil) ;; performance
        (zmc-async-shell-command-spinners-enable t) ;; to enable starting the spinner 
        )
    (save-window-excursion
      (zmc-async-shell-command+ cmd bufnm))))


(defun zmc-es-detached (cmd)
  (let ((bufnm (zmc-compute-bufnm))
        ;;(process-connection-type nil) ;; doesn't work with detached
        )
    (let ((detached--shell-command-buffer bufnm))
      (detached-shell-command cmd))
    bufnm))

(defun zmc-es-detached+ (cmd)
  (let ((bufnm (zmc-compute-bufnm))
        ;;(process-connection-type nil) ;; doesn't work with detached
        (zmc-async-shell-command-spinners-enable t) ;; to enable starting the spinner 
        )
    (zmc-detached-shell-command+ cmd bufnm)
    bufnm))


(defun zmc-es-vterm (cmd)
  ;; if bufnm exists kill it
  (let* ((bufnm (zmc-compute-bufnm)))
    ;; todo make this configurable, should it kill, switch to it,
    ;; create new with uniquify name, prompt for name? prompt for any
    ;; of these options?
    (when (get-buffer bufnm)
      (kill-buffer bufnm))
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
         (select (or (ht-get target "select") "no"))
         (buffer-replace-policy (or (ht-get target "buffer-replace-policy") "default-buffer-replace-policy"))
         (transient-name (string-replace " " "-" (ht-get target "key"))) ; TODO redundant logic
         )
    (setq latest-cmd cmd)
    (set (make-local-variable 'local-cmd) cmd)
    (apply 'zmc-run `(,program ,cmd ,bufnm ,side ,slot ,select ,buffer-replace-policy ,transient-name))))


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
       ])))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; DETECTORS
(defun zmc-infer-program (build-file-type)
  (cond
   ((string= build-file-type "make") "async-shell-command+")
   ((string= build-file-type "pytest") "async-shell-command+")
   ((string= build-file-type "tmuxinator") "vterm")
   ))

(defun zmc-make-template (build-file-name target)
  (cond
   ((string= build-file-type "make")
    (concat "make -f " build-file-name " " target))
   ((string= build-file-type "tmuxinator")
    (concat "tmuxinator start --suppress-tmux-version-warning -p " build-file-name))
   ((string= build-file-type "pytest")
    (concat "poetry run pytest -vvv " target))))




(defun zmc-get-parent-dirs (path)
  (let* ((path (string-join (butlast (split-string path "/")) "/"))
         (path (if (string= path "") "/" path)))
    (if (string= path "/") '() (cons path (zmc-get-parent-dirs path)))))

(defun zmc-get-pytest-targets-from-project (project-path)
  (let* ((paths (shell-command-to-string
                 (concat
                  "cd " project-path " && "
                  "poetry run pytest "
                  "--co -q --disable-warnings")))
         (paths (nth 0 (split-string paths "\n\n")))
         (paths (split-string paths "\n"))
         (paths (--map (substring it 0 (string-match "\\[" it))
                       paths))
         (paths (append
                 ;; function level
                 (delete-dups paths) 
                 ;; file level
                 (delete-dups (--map (nth 0 (split-string it "::"))
                                     paths)) 
                 ;; parent dir level
                 (delete-dups (-flatten (--map (zmc-get-parent-dirs it)
                                               paths))))))
    paths))


(defun zmc-make-alist (project-path build-file-name build-file-type)
  (let* ((fname (concat project-path build-file-name))
         (subtargets (cond
                      ((string= build-file-type "make")
                       (projection-multi-make--targets-from-file2 fname))
                      ((and (string= build-file-type "pytest")
                            (string= (projectile-project-p) (expand-file-name project-path)))
                       (zmc-get-pytest-targets-from-project project-path))
                      ((string= build-file-type "tmuxinator")
                       ;; eg no subtargets
                       '(""))))
         (dirname (file-name-nondirectory (directory-file-name project-path)))
         (alist (--map
                 `(,(concat dirname " > " build-file-type " > " build-file-name " > " it)
                   .
                   ;; TODO add point aware things like function name? file name?
                   ;; need a reliably (eg treesit) approach to doing this
                   ,(ht-from-alist
                     `(("template" . ,(zmc-make-template build-file-name it))
                       ("directory" . ,project-path)
                       ("program" . ,(zmc-infer-program build-file-type)))))
                 subtargets)))
    (ht-from-alist alist)))

(defun zmc-get-targets (project-path build-file-type &optional regex)
  (--map
   (let* ((build-file-name (when (file-exists-p (concat project-path it)) it)))
     (when build-file-name
       (zmc-make-alist project-path build-file-name build-file-type)))
   (directory-files project-path nil regex t)))

;; This should be the function that we define per build target type
(defun zmc-detect-targets (build-file-type regex)
  (let* ((projects (--filter (not (string= it "~/")) projectile-known-projects))
         (lst (--map (zmc-get-targets it build-file-type regex) projects))
         (lst (--filter it lst))
         (lst (flatten-list lst)))
    (eval (append '(ht-merge) lst))))


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
   (t (let* ((detected-targets (ht-merge
                                (zmc-detect-targets "make" "makefile\\|Makefile")
                                (zmc-detect-targets "pytest" "pyproject.toml")
                                (zmc-detect-targets "tmuxinator" "\\.tmuxinator\\.yaml")
                                (eval (append
                                       '(ht-merge)
                                       (--filter it (zmc-get-targets
                                                     "~/.config/tmuxinator/" "tmuxinator" ""))))))
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


