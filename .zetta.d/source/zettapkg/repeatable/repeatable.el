;;; -*- lexical-binding: t -*-


;; NOTE: stolen from which-key
(defun reload-key-sequence (&optional key-seq)
  (let* ((key-seq (or key-seq (which-key--current-key-list)))
         (next-event (mapcar (lambda (ev) (cons t ev)) key-seq)))
    (setq prefix-arg current-prefix-arg
          unread-command-events next-event)))


(setq my-this-command-keys-vector nil)

;; LEFTOFF -- still struggling, but got to a state... still figuring
;; out how to recover from after applying a universal arg.... this
;; might not be worth the squeeze for me honestly...  do I ever use
;; universal args?  Maybe give this 1 more session then abandon to
;; universal arg feature or maybe leave it in its current state or
;; just back this up then simplify...
;;; NOTE might need to reset the universal prefix elsewhere? maybe in
;;; an uniwind protecT?
(defun my-read-key-sequence (prefix)
  (let* ((key-sequence-vector (read-key-sequence-vector nil))
         (key-sequence-vector (if (equal key-sequence-vector [])
                                  (let* ((unread-command-events nil)
                                         (_ (setq current-prefix-arg nil))
                                         (kkkey (read-char))
                                         (vec (vconcat (remove-universal-arg prefix)
                                                       (make-vector 1 kkkey)))
                                         ;;(_ (setq my-this-command-keys-vector vec))
                                         (_ (reload-key-sequence (remove-universal-arg vec)))
                                         )
                                    (message "reloading")
                                    (message "reset this command keys vector")
                                    ;;(setq my-this-command-keys-vector nil)
                                    (remove-universal-arg vec)
                                    )
                                key-sequence-vector
                                ))
         (_ (message "key-sequence-vector %s" (message-vector key-sequence-vector)))
         (last-key-vector (vector
                           (aref key-sequence-vector
                                 (1- (length key-sequence-vector)))))
         (last-key (key-description last-key-vector))
         (_ (when (string= last-key "C-u")
              (let* ((key-sequence-vector
                      (vconcat
                       [21]
                       (seq-take key-sequence-vector
                                 (1- (length key-sequence-vector))))))
                (reload-key-sequence key-sequence-vector)
                (setq my-this-command-keys-vector key-sequence-vector)
                (while (progn (let ((unread-command-events nil))
                                (setq kkey (read-key))) (equal kkey ?\C-u))
                  (message "adding a universal arg")
                  (setq key-sequence-vector (vconcat [21] key-sequence-vector))
                  (setq my-this-command-keys-vector key-sequence-vector)
                  (reload-key-sequence key-sequence-vector))
                (setq my-this-command-keys-vector nil)
                (progn
                  (setq last-key-vector (make-vector 1 kkey))
                  (setq last-key (key-description last-key-vector))))))
         (_ (setq previous-key-sequence-vector key-sequence-vector))
         (key (key-description key-sequence-vector))
         (local-binding (keymap-lookup nil key))
         (global-binding (keymap-lookup nil last-key)))
    (cond
     ((string= last-key "C-h") (funcall prefix-help-command))
     ((string= last-key "C-g") (keyboard-quit))
     (local-binding (progn (call-interactively local-binding)))
     (global-binding
      (cond
       ((keymapp global-binding)
        (reload-key-sequence last-key-vector)
        (setq prefix-help-command 'versatile-C-h))
       (t 
        (execute-kbd-macro last-key-vector)
        (setq prefix-help-command 'versatile-C-h))))
     ((string= last-key "C-S-x")
      (reload-key-sequence [24])
      (setq prefix-help-command 'versatile-C-h))
     (t (message "No binding in local or global maps %s" key)))))


(defun remove-universal-arg (vec)
  (vconcat (remove 21 (append vec nil))))


(defun message-vector (vec)
  "Message the contents of a vector VEC."
  (mapconcat 'number-to-string (append vec nil) " "))


(defmacro repeatable (function)
  `(defun ,(intern (format "*%s" function)) ()
     (interactive)
     (let* ((keys (this-command-keys-vector))
            (_ (message "this command keys %s" (message-vector keys)))
            (keys (remove-universal-arg keys))
            (prefix (seq-take keys (1- (length keys))))
            (_ (message "prefix %s" (message-vector prefix))))
       (call-interactively ',function)
       ;;(setq current-prefix-arg nil)
       (reload-key-sequence prefix)
       (setq prefix-help-command 'versatile-C-h)
       (my-read-key-sequence prefix)
       (setq my-this-command-keys-vector nil)
       )))


;; Usage
(defun foo (&optional arg) (interactive "P") (if arg (message "foo") (message "FOO")))
(defun bar () (interactive) (message "bar"))
(defun baz () (interactive) (completing-read "foo" '("foo" "bar")))

(general-define-key
 :keymaps 'override
 "C-c o m" (repeatable foo)
 "C-c o M" (repeatable bar)
 "C-c o P" 'foo
 "C-c o x p" 'foo
 "C-c o c" (repeatable baz))


(provide 'repeatable)
