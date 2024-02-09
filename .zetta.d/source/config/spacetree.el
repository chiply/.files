;; rules - use strings for hash table keys
;; get window


;; way to preserve state at each level? for example when switching to
;; the higher level workspace, it should know when sublevel was
;; showing -- this is how winds works.

;; function for recording window configuration in st
;; function for binding configuration to address
;; function for restoring window configuraiton to value in address
;; function to save current configuration
;; function to visualize window configurations (eg st)


;; KUI:
;; new-workspace
;; new-workspace-subdivide
;; switch-workspace
;; save-workspace-by-address
;; restore-workspace-by-address

;; create a nested hashtable using ht
(require 'ht)

;; create the hash table with some data
(message "\n\n\nSTART==================")



;; initial state
(defun st-inititialize ()
  ;;(ht-set st-spaces '(0) (winner-conf)) ;; don't need this, it will
  ;;be saved when switching away for the first time
  )

(setq st (ht-create))
(setq st-spaces (ht-create))

(ht-set st "spacetree" (ht-create))

(ht-set (ht-get* st "spacetree") 0 nil)
(setq st-current-space-address '(0))


(butlast '(1 2 3))
(last '(1 2 3) 1)

;; add workspace
(defun st-add-workspace (address)
  (setq address '(1 2))
  (eval
   (if (> (length address) 1)
       (append
        `(ht-set ,(append '(ht-get* st "spacetree") (butlast address)))
        (append `(,(car (last address 1))) '(nil)))
     (append '(ht-set (ht-get* st "spacetree")) `(,(car address) nil))
     )
   )
  (ht-set st-spaces address (winner-conf))
  )

;; left off -- just got the st-add-workspace function to work, need to test it out with nested addresses

(st-add-workspace '(1))
(st-add-workspace '(2))
(st-add-workspace '(3))
(st-add-workspace '(1 2)) ;; LEFT OFF

(setq st-current-space-address address)
(ht-set st-spaces address (winner-conf))

;; subdivide 0
(ht-set (ht-get* st "spacetree") 0 (ht-create)) ;; subdivision

(ht-set (ht-get* st "spacetree" 0) 0 nil)
(setq st-current-space-address '(0 0))
(ht-set st-spaces '(0 0) (winner-conf))

(ht-set (ht-get* st "spacetree" 0) 1 nil)
(setq st-current-space-address '(0 1))
(ht-set st-spaces '(0 1) (winner-conf))

(message (yaml-encode st))


;; for ease of use -- can we maintain a flat hash map with the names of configurations ()


;; NOTE can use (eval (append '(message logmsg) formatparams)) trick
;; to bring in a path represented as a list of hash table keys and
;; pass to ht-get*
;; (eval (append '(ht-get* st "spacetree") st-current-space-address))

;; (eval (append '(ht-get* st "spacetree") st-current-space-address))




(message "END==================\n\n\n")



