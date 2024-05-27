;; key setup requirements
;; 1. easy to define keys for meow, evil, and vanilla emacs; support for general chord
;; 2. use of built-ins for simple usecases like repeat mode
;; 3. is hercules obsolete?  should support anyway
;; 4. support for bulkier UIS like transient, hydras, but only when their differential UI features are required (magit, zmc)

(defun command1 () (interactive) (message "command1"))
(defun command2 () (interactive) (message "command2"))
(defun command3 () (interactive) (message "command3"))


;; keymap
(defvar some-map (make-sparse-keymap))

(general-define-key
 :keymaps 'some-map
 "1" 'command1
 "2" 'command2
 "3" 'command3
 "41" 'command1
 "42" 'command2)

;; TODO -- replace with define-launch-key bind some-map a key
(global-set-key (kbd "C-=") some-map)

(define-launch-key 'some-map)


;;;;;;;;;;;;; REPEAT

;; (defvar-keymap comma-repeat-map
;;     :repeat (:enter (command1) :exit (command3))
;;     "1" #'command1
;;     "2" #'command2
;;     "3" #'command3)

;;;; repeatize for existing keymaps
;; (defun repeatize (keymap)
;;   "Add `repeat-mode' support to a KEYMAP."
;;   (map-keymap
;;    (lambda (_key cmd)
;;      (when (symbolp cmd)
;;        (put cmd 'repeat-map keymap)))
;;    (symbol-value keymap)))
;; (repeatize 'some-map)

;;;; define-repeat-map.el (probably redundant)
;; (use-package define-repeat-map
;;   :straight (define-repeat-map :type git :host nil :repo "https://tildegit.org/acdw/define-repeat-map.el" ))
;; (define-repeat-map command1
;;     ("1" command1
;;      "2" command2
;;      ))

;; maybe redundnat, but provides interesting feature of turning an entire keymap into a repeat map... although doesn't repeatize do this?  so maybe hercules over repeatize as it is finer grained?
;; (use-package hercules)
;; (hercules-def
;;  :toggle-funs #'command1
;;  :keymap 'some-map
;;  :transient t)




;;;;;;;;;;; UI

;; hydra

;; transient
