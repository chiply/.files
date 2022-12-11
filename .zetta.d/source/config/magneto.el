                                        ;TODO: framework-ify -- document exactly how to add new actions and embark-actions

;;TODO: ace selection anywhere in key sequence DONE,
;;TODO:  can improve by incorporating the initial key stroke (a,s,f) as initial inpit to avy-read DONE
;;TODO: reset to default settings each time, maybe have an option for 'repeat last command' DONE


                                        ;TODO: how to make this play nicely with embark? look at karthik implementation https://karthinks.com/software/fifteen-ways-to-use-embark/.  Leave this for way later as it will depend on the magneto function in the same way it depends on the ace function as in my/embark-magneto-action


;; redifining avy-read to allow initial input
(defun magneto-avy-read (initial-input tree display-fn cleanup-fn)
  (catch 'done
    (setq avy-current-path initial-input)
    ;; set counter
    (setq counter 0)
    (while tree
      ;; increment counter
      (setq counter (+ 1 counter))
      (let ((avy--leafs nil))
        (avy-traverse tree
                      (lambda (path leaf)
                        (push (cons path leaf) avy--leafs)))
        (dolist (x avy--leafs)
          (funcall display-fn (car x) (cdr x))))
      (let ((char (funcall
                   avy-translate-char-function
                   (if (eq counter 1)
                       ;; first time round, give the sequence literally
                       (cond
                        ((string-equal initial-input "a") 97)
                        ((string-equal initial-input "s") 115)
                        ((string-equal initial-input "d") 100)
                        )
                     (read-key))))
            window
            branch)
        (funcall cleanup-fn)
        (if (setq window (avy-mouse-event-window char))
            (throw 'done (cons char window))
          (if (setq branch (assoc char tree))
              (progn
                ;; Ensure avy-current-path stores the full path prior to
                ;; exit so other packages can utilize its value.
                (setq avy-current-path
                      (concat avy-current-path (string (avy--key-to-char char))))
                (if (eq (car (setq tree (cdr branch))) 'leaf)
                    (throw 'done (cdr tree))))
            (funcall avy-handler-function char)))))))



;; Adapted from aw-select
(defun magneto-ace-get-window (initial-input)
  (interactive)
  "Selecting with ace window"
  (let* ((wnd-list (aw-window-list))
         (candidate-list
          (mapcar (lambda (wnd)
                    (cons (aw-offset wnd) wnd))
                  wnd-list))
         (win (cdr (magneto-avy-read initial-input (avy-tree candidate-list aw-keys)
                                     (if (and ace-window-display-mode
                                              (null aw-display-mode-overlay))
                                         (lambda (_path _leaf))
                                       aw--lead-overlay-fn)
                                     aw--remove-leading-chars-fn
                                     )))
         )
    (message "window selected with magneto-ace-get-window")
    win
    ))



;; Defaults
(setq magneto-default-source-action "move"
      magneto-default-destination-action "f"
      magneto-default-select-action "o"
      magneto-default-action-action "switch-buffer"
      magneto-default-destination-window nil
      magneto-default-embark-candidate nil
      magneto-default-embark-action nil
      )


(defun magneto-make-indirect ()
  (interactive)
  (switch-to-buffer
   (clone-indirect-buffer
    (format "*indirect--%s*" (buffer-name (current-buffer)))
    nil)))


(defun magneto-restore-defaults ()
  (interactive)
  (setq magneto-source-action magneto-default-source-action
        magneto-destination-action magneto-default-destination-action
        magneto-select-action magneto-default-select-action
        magneto-action-action magneto-default-action-action
        magneto-destination-window magneto-default-destination-window
        magneto-embark-candidate magneto-default-embark-candidate
        magneto-embark-action magneto-default-embark-action
        ))

;; Instantiates the variables from Defaults
(magneto-restore-defaults)





(defun magneto-move-after-select (buf-orig)
  (cond
   ((string= magneto-destination-action "f") nil)
   ((string= magneto-destination-action "V") (split-window))
   ((string= magneto-destination-action "v") (split-window) (windmove-down))
   ((string= magneto-destination-action "H") (split-window-horizontally))
   ((string= magneto-destination-action "h") (split-window-horizontally) (windmove-right)))

  (cond
   ;; switch-buffer is candidateless, this would never be supplied by
   ;; embark
   (magneto-embark-action (progn (message "HEYOOO") (funcall magneto-embark-action magneto-embark-candidate))) ; note the lack of '
   ((string= magneto-action-action "switch-buffer")
    (switch-to-buffer buf-orig))
   ;; candidates possibly coming from embark
   ((string= magneto-action-action "execute-command")
    (call-interactively (execute-extended-command nil))
    
    )
   ((string= magneto-action-action "find-file")
    (call-interactively 'find-file)
    )
   ((string= magneto-action-action "consult-buffer")
    (consult-buffer)
    )
   )
  

  (selected-window)
  )



(defun magneto-select-win-dest-ace (buf-orig)
  (if magneto-destination-window
      ;; if a window was specified already...
      (progn
        ;;(message (concat "foo-bar" magneto-destination-window))
        (select-window magneto-destination-window)
        (magneto-move-after-select buf-orig))
    ;; otherwise, invoke ace-window now
    (progn
      ;;(message "hello")
      (aw-select
       "Select a window!: "
       (lambda (window)
         (aw-switch-to-window window)
         (magneto-move-after-select buf-orig)
         )))
    )

  )

(defun magneto-select-win-dest-side (buf-orig)
  (let ((side (cond
               ((member magneto-destination-action '("t" "T")) 'top)
               ((member magneto-destination-action '("b" "B")) 'bottom)
               ((member magneto-destination-action '("r" "R")) 'right)
               ((member magneto-destination-action '("l" "L")) 'left)))
        (slot (cond
               ((member magneto-destination-action '("t" "b" "r" "l")) 10)
               ((member magneto-destination-action '("T" "B" "R" "L")) -10)))
        )
    (display-buffer
     buf-orig
     `((display-buffer-in-side-window)
       (side . ,side)
       (slot . ,slot)
       (window-parameters . ((no-delete-other-windows . 1)))))))


(defun magneto-select-win-dest (buf-orig)
  (cond
   ((member magneto-destination-action '("f" "V" "v" "H" "h"))
    (magneto-select-win-dest-ace buf-orig))
   ((member magneto-destination-action '("t" "T" "b" "B" "r" "R" "l" "L"))
    ;; Note: returns the window
    (magneto-select-win-dest-side buf-orig))))


(defun magneto-process-source (win-orig)
  (cond
   ((string= magneto-source-action "move") (delete-window win-orig))
   ((string= magneto-source-action "pull") (switch-to-prev-buffer win-orig))
   ((string= magneto-source-action "copy") nil)))


(defun magneto-process-select (win-orig win-dest)
  (cond
   ((string= magneto-select-action "o") (select-window win-dest))
   ((string= magneto-select-action "O") (select-window win-orig))))


(defun magneto-move (&optional repeat)
  (interactive)
  (let* ((buf-orig (current-buffer))
         (win-orig (selected-window))
         ;; CREATE-MAYBE
         (win-dest (magneto-select-win-dest buf-orig)))
    ;;;; CLEAN-MAYBE
    (message "processing source")
    (magneto-process-source win-orig)
    ;;;; PLACE-CURSOR
    (message "processing select")
    (magneto-process-select win-orig win-dest)
    )
  )



;; Factoring the setter functions is useful because we can enrich to
;; include small reports or indications of what happened -- eg "window
;; was selcted via the command ''.  move is still legal"
(defun magneto-set-magneto-source-action (setting)
  (interactive)
  (setq magneto-source-action setting)
  )

(defun magneto-set-magneto-destination-action (setting)
  (interactive)
  (setq magneto-destination-action setting)
  )

(defun magneto-set-magneto-selection-action (setting)
  (interactive)
  (setq magneto-selection-action setting)
  )

(defun magneto-set-magneto-action-action (setting)
  (interactive)
  (setq magneto-action-action setting)
  )

(defun magneto-set-magneto-destination-window (setting)
  (interactive)
  (setq magneto-destination-window (magneto-ace-get-window setting)))


(defhydra+ hydra-magneto ()
  "
%s(concat magneto-source-action \"-\" magneto-destination-action \"-\" magneto-select-action \"-\" magneto-action-action)
"
  ;; run the exit function, eg execute the move specifed by 
  ("s-m" magneto-move)
  ("<return>" magneto-move)

  ;; run previous (tbd how we will cache the previous move's settings)

  ;; source actions
  ("m" (magneto-set-magneto-source-action "move") "move" :column "source actions")
  ("c" (magneto-set-magneto-source-action "copy") "copy")
  ("p" (magneto-set-magneto-source-action "pull") "pull")

  ;; destniation actions
  ("0" (magneto-set-magneto-destination-action "f") "f" :column "destination actions")
  ("h" (magneto-set-magneto-destination-action "h") "h")
  ("H" (magneto-set-magneto-destination-action "H") "H")
  ("v" (magneto-set-magneto-destination-action "v") "v")
  ("V" (magneto-set-magneto-destination-action "V") "V")
  ("t" (magneto-set-magneto-destination-action "t") "t")
  ("T" (magneto-set-magneto-destination-action "T") "T")
  ("b" (magneto-set-magneto-destination-action "b") "b")
  ("B" (magneto-set-magneto-destination-action "B") "B")
  ("l" (magneto-set-magneto-destination-action "l") "l")
  ("L" (magneto-set-magneto-destination-action "L") "L")
  ("r" (magneto-set-magneto-destination-action "r") "r")
  ("R" (magneto-set-magneto-destination-action "R") "R")

  ;; selection actions
  ("o" (magneto-set-magneto-selection-action "o") "o"  :column "selection actions")
  ("O" (magneto-set-magneto-selection-action "O") "O")

  ;; action actions
  ("w" (magneto-set-magneto-action-action "consult-buffer") "consult-buffer" :column "action actions")
  ("x" (magneto-set-magneto-action-action "execute-command") "execute-command")
  ("f" (magneto-set-magneto-action-action "find-file") "find-file")
  ("C-b" (magneto-set-magneto-action-action "switch-buffer") "switch-buffer")

  ;; note only a-d are used for ace
  ("a" (magneto-set-magneto-destination-window "a") "select window" :column "ace window")
  ("s" (magneto-set-magneto-destination-window "s") "select window")
  ("d" (magneto-set-magneto-destination-window "d") "select window"))


(defun magneto ()
  (interactive)
  (magneto-restore-defaults)
  (hydra-magneto/body))




;; embark integration
(eval-when-compile
  (defmacro my/embark-magneto-action (fn)
    `(defun ,(intern (concat "my/embark-magneto-" (symbol-name fn))) ()
       (interactive)
       (with-demoted-errors "%s"
         (magneto-restore-defaults)
         ;; set the action and candidate
         (setq
          ;; the action should be an interactive command
          magneto-embark-candidate (read-from-minibuffer "foobar prompt: ")
          magneto-embark-action ',fn)
          ;;(message magneto-embark-action)
          ;;(error "foo")
          (hydra-magneto/body)
          ))))


;; the action should be an interactive command
(define-key embark-file-map     (kbd "o") (my/embark-magneto-action find-file))
(define-key embark-buffer-map   (kbd "o") (my/embark-magneto-action switch-to-buffer))
(define-key embark-bookmark-map (kbd "o") (my/embark-magneto-action bookmark-jump))


(general-define-key
 :keymaps 'override
 "s-m" 'magneto)



;; also see if we really can make a unifieed interactive function that can be used for both -- this would come after implementing the above, not alternative to

