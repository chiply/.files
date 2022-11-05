;; default splitting style
(setq magneto-default-source-action "move" magneto-default-destination-action "f"
      magneto-default-select-action "o" magneto-default-action-action "switch-buffer")

;; todo Make indirect buffer from this buff
(defun magneto-make-indirect ()
  (interactive)
  (switch-to-buffer
   (clone-indirect-buffer (format "*indirect--%s*" (buffer-name (current-buffer))) nil)))

;;; defaults
(defun magneto-restore-defaults ()
  (interactive)
  (setq magneto-source-action magneto-default-source-action
        magneto-destination-action magneto-default-destination-action
        magneto-select-action magneto-default-select-action
        magneto-action-action magneto-default-action-action))

;; instantiates the variables from defaults
(magneto-restore-defaults)

;; move is moving the windows, entering is placing the cursor somewhere
(defun magneto-move (&optional repeat)
  ;; destination window gets recorded at some point?  depends on
  ;; window getting created at runtime
  
  (interactive)
  ;; Some buffer at source is source is store
  ;;(unless repeat (magneto-restore-defaults))
  (let* (
         ;; TODO -- or some other buffer (optional arg?)
         (buf-orig (current-buffer))
         (win-orig (selected-window))
         ;;;; DESTINATION
         (win-dest (cond
                    ;; destination actions relying on ACE, can place in side windows
                    ((member magneto-destination-action '("f" "V" "v" "H" "h"))
                     (aw-select
                      "Select a window: "
                      (lambda (window)
                        (aw-switch-to-window window)
                        (cond
                         ((string= magneto-destination-action "f") nil)
                         ((string= magneto-destination-action "V") (split-window))
                         ((string= magneto-destination-action "v") (split-window) (windmove-down))
                         ((string= magneto-destination-action "H") (split-window-horizontally))
                         ((string= magneto-destination-action "h") (split-window-horizontally) (windmove-right)))
                        ;;;; ACTION-ACTION
                        ;; TODO parameterize with action -- should be a cond!!!!
                        (cond
                         ;; this is the "moving" action... the default
                         ((string= magneto-action-action "switch-buffer")
                          (switch-to-buffer buf-orig))
                         ((string= magneto-action-action "execute-command")
                          (call-interactively (execute-extended-command nil)))
                         ;; TODO this will defy expectation that user
                         ;; will be prompted for file from current
                         ;; dir... is this okay?
                         ((string= magneto-action-action "find-file")
                          (call-interactively 'find-file))
                         ((string= magneto-action-action "consult-buffer")
                          (consult-buffer)) ;; doesn't follow vertico rules?
                         ) ;; default
                        (selected-window)
                        )))
                    ;; destination actions relying on creating a new SIDE window
                    ((member magneto-destination-action '("t" "T" "b" "B" "r" "R" "l" "L"))
                     ;; Note: returns the window
                     (display-buffer
                      buf-orig
                      `((display-buffer-in-side-window)
                        (side . ,(cond
                                  ((member magneto-destination-action '("t" "T")) 'top)
                                  ((member magneto-destination-action '("b" "B")) 'bottom)
                                  ((member magneto-destination-action '("r" "R")) 'right)
                                  ((member magneto-destination-action '("l" "L")) 'left)))
                        (slot . ,(cond
                                  ((member magneto-destination-action '("t" "b" "r" "l")) 10)
                                  ((member magneto-destination-action '("T" "B" "R" "L")) -10)))
                        (window-parameters . ((no-delete-other-windows . 1)))))))))

    (message "processing source")
    ;;;; SOURCE
    (cond
     ((string= magneto-source-action "move") (delete-window win-orig))
     ((string= magneto-source-action "pull") (switch-to-prev-buffer win-orig))
     ((string= magneto-source-action "copy") nil)
     )

    (message "processing select")
    ;;;; SELECT
    ;; note only pull and copy source actions have the notion of select vs no select.  move closes the source window
    (cond
     ((string= magneto-select-action "o") (select-window win-dest))
     ((string= magneto-select-action "O") (select-window win-orig))
     )

    )
  (magneto-restore-defaults)
  )

;; Nice thing about setting up the UI in this way is that, whether
;; with which key or hercules you are always seeing ALL the options,
;; not just some key and hidden values... need to organize into
;; columns for this reason!  To represent categotires

;; FEATURE -- needs to be a switch to window hydra.j imagining a large
;; interface with not only the movement capabilities but general
;; manipulation capabilities, or which these specialized capabilities
;; are some.
(defhydra+ hydra-magneto ()
  "
%s(concat magneto-source-action \"-\" magneto-destination-action \"-\" magneto-select-action \"-\" magneto-action-action)
"
  ;; run the exit function, eg execute the move specifed by 
  ("s-m" magneto-move)
  ("<return>" magneto-move)

  ;; run previous (tbd how we will cache the previous move's settings)

  ;; source actions
  ("m" (lambda () (interactive) (setq magneto-source-action "move")) "move")
  ("c" (lambda () (interactive) (setq magneto-source-action "copy")) "copy")
  ("p" (lambda () (interactive) (setq magneto-source-action "pull")) "pull")

  ;; destniation actions
  ("0" (lambda () (interactive) (setq magneto-destination-action "f")) "f")
  ("h" (lambda () (interactive) (setq magneto-destination-action "h")) "h")
  ("H" (lambda () (interactive) (setq magneto-destination-action "H")) "H")
  ("v" (lambda () (interactive) (setq magneto-destination-action "v")) "v")
  ("V" (lambda () (interactive) (setq magneto-destination-action "V")) "V")
  ("t" (lambda () (interactive) (setq magneto-destination-action "t")) "t")
  ("T" (lambda () (interactive) (setq magneto-destination-action "T")) "T")
  ("b" (lambda () (interactive) (setq magneto-destination-action "b")) "b")
  ("B" (lambda () (interactive) (setq magneto-destination-action "B")) "B")
  ("l" (lambda () (interactive) (setq magneto-destination-action "l")) "l")
  ("L" (lambda () (interactive) (setq magneto-destination-action "L")) "L")
  ("r" (lambda () (interactive) (setq magneto-destination-action "r")) "r")
  ("R" (lambda () (interactive) (setq magneto-destination-action "R")) "R")

  ;; selection actions
  ("o" (lambda () (interactive) (setq magneto-selection-action "o")) "o" )
  ("O" (lambda () (interactive) (setq magneto-selection-action "O")) "O")

  ;; action actions
  ("C-b" (lambda () (interactive) (setq magneto-action-action "switch-buffer")) "switch-buffer")
  ("w" (lambda () (interactive) (setq magneto-action-action "consult-buffer")) "consult-buffer")
  ("x" (lambda () (interactive) (setq magneto-action-action "execute-command")) "execute-command")
  ("f" (lambda () (interactive) (setq magneto-action-action "find-file")) "find-file")
  )

(general-define-key
 :keymaps 'override
 "s-m" 'hydra-magneto/body
 )



