;; add some text to the top hyah

;; create a nested hashtable using ht
(require 'ht)


(defvar st) ;; the ht representing the space tree
(defvar st-current-space-address) ;; the address of the current space
(defvar st-spaces) ;; the ht that stores the spaces
(defvar st-history '()) ;; the history of the spaces
(defvar st-named-workspaces (ht-create))



(defun st-history-match (history sublist)
  (let ((n (length sublist)))
    (car (-filter
          (lambda (x) (equal (butlast x (- (length x) n)) sublist))
          history))))


(defun st-init ()
  (interactive)
  (setq st (ht-create))
  (setq st-spaces (ht-create))
  (setq st-named-workspaces (ht-create))
  (setq st-history '())
  (ht-set st "spacetree" (ht-create))
  (st-add-workspace '(1))
  (force-mode-line-update))


(defun st-add-workspace (address)
  (let ((code (append
               '(ht-set)
               `(,(-filter
                   (lambda (x) x)
                   (append '(ht-get* st "spacetree")
                           (butlast address))))
               (last address)
               '((ht-create)))))
    (eval code)
    (setq st-current-space-address address)
    (ht-set st-spaces address (winner-conf))
    (setq st-history (cons st-current-space-address st-history))
    (st-delete-other-windows-and-switch-to-scratch)
    code))


(defun st-switch (new-address)
  (interactive)
  (let* ((old-address st-current-space-address)
         (workspace (ht-get st-spaces new-address)))
    (ht-set st-spaces old-address (winner-conf))
    (cond ((not workspace)
           (st-add-workspace new-address))
          ((st-history-match st-history new-address)
           (winner-set (ht-get st-spaces (st-history-match st-history new-address)))
           (setq st-current-space-address (st-history-match st-history new-address))
           (setq st-history (cons st-current-space-address st-history))
           )
          (t
           (winner-set workspace)
           (setq st-current-space-address new-address)
           (setq st-history (cons st-current-space-address st-history)))))
  (force-mode-line-update))



(defun st-current-depth ()
  (length st-current-space-address))


(defun st-switch-current-level (i)
  (st-switch (append (butlast st-current-space-address) `(,i))))


(defun st-subdivide ()
  "Subdivides an st workspace"
  (interactive)
  (let ((saved-workspace-address (append st-current-space-address '(1)))
        (new-workspace-address (append st-current-space-address '(2))))
    (st-add-workspace saved-workspace-address)
    (st-add-workspace new-workspace-address)))


(defun st-add-workspace-current-level ()
  (interactive)
  (st-add-workspace
   (append
    (butlast st-current-space-address)
    `(,(+ 1
          (apply
           'max
           (ht-keys
            (eval (append
                   '(ht-get* st "spacetree")
                   (butlast st-current-space-address))))))))))


(defun st-switch-current-level (i)
  (st-switch (append (butlast st-current-space-address) `(,i))))

(defun st-name-workspace (name)
  (interactive "sName: ")
  (ht-set st-named-workspaces st-current-space-address name)
  (force-mode-line-update))


(defun st-switch-space-by-name ()
  (interactive)
  (let* ((st-named-workspaces-reversed  (-map
                                         (lambda (x) `(,(cdr x) . (,(car x))))
                                         (ht-to-alist st-named-workspaces)))
         (name (completing-read
                "Select a named workspace: "
                st-named-workspaces-reversed))
         (address (car
                   (ht-get
                    (ht-from-alist st-named-workspaces-reversed)
                    name))))
    (st-switch address)))


(defun st-delete-other-windows-and-switch-to-scratch ()
  (delete-other-windows)
  (switch-to-buffer (get-buffer-create "*scratch*")))


(defun st-modeline-lighter ()
  (let ((modeline-string ""))
    (dotimes (i (st-current-depth))
      (let* ((level-address (butlast st-current-space-address (- (st-current-depth) i)))
             (level-space (nth i st-current-space-address)))
        (let ((node (eval (append '(ht-get* st "spacetree") level-address))))
          (setq
           modeline-string
           (concat
            modeline-string
            (mapconcat (lambda (x)
                         ;;;;debugging
                         ;;(message (mapconcat (lambda (x) (number-to-string x)) (append level-address `(,x))))
                         ;;(if (ht-get st-named-workspaces (append level-address `(,x)))
                         ;;(message "hit")
                         ;;(message "miss")
                         ;;)
                         (let* ((workspace-name (ht-get st-named-workspaces (append level-address `(,x))))
                                (_string (if workspace-name workspace-name (number-to-string x))))
                           (if (equal x level-space)
                               ;; need to change text to update modeline
                               (propertize (concat _string "* ") 'face 'bold)
                             (concat _string " "))))
                       (reverse (ht-keys node)))
            "| ")))))
    (setq modeline-string (substring modeline-string 0 -2))
    (concat "{ " modeline-string "}")))




;; st
;; st-spaces
;; st-history

;; turn the above into a hydra
;; This Hydro will be useful but it's mainly a testing ground for
;; global key bindings that are going to end up in the global globally
;; accessible came up. The reason we stopped into this Hydro first is
;; because we want to make sure that they actually make economic
;; sense, and the fact that they are in a hydra and we don't have to
;; repeatedly invoke the hyWe get a similar looking feel as if he's
;; key bindings where it's actually Dublin here's a useful
;; developmental, but there might be some hydra. Probably from the
;; coding perspective, as soon as we take stains out of this Hydro put
;; them into the global key bindings it might seem like a good idea to
;; remove them from the hydra, but I'm not gonna do that because I
;; want the entire KUI to be encapsulated in the hydra.
(defhydra st-hydra (:color red)
  "spacetree"
  ;; because this is prefixed, this is a nice place to try out the KUI
  ("i" st-init "init")
  ("s" st-subdivide "subdivide")
  ("w" st-add-workspace-current-level "add workspace")
  ("N" st-name-workspace "name workspace")
  ("n" st-switch-space-by-name "switch by name")

  ;; switch same (st-current-depth)
  ("1" (lambda () (interactive) (st-switch-current-level 1)) "switch 1")
  ("2" (lambda () (interactive) (st-switch-current-level 2)) "switch 2")
  ("3" (lambda () (interactive) (st-switch-current-level 3)) "switch 3")
  ("4" (lambda () (interactive) (st-switch-current-level 4)) "switch 4")
  ("5" (lambda () (interactive) (st-switch-current-level 5)) "switch 5")
  ("6" (lambda () (interactive) (st-switch-current-level 6)) "switch 6")

  ;; switch top (st-current-depth)
  ("s-1" (lambda () (interactive) (st-switch '(1))) "switch C-1")
  ("s-2" (lambda () (interactive) (st-switch '(2))) "switch C-2")
  ("s-3" (lambda () (interactive) (st-switch '(3))) "switch C-3")
  ("s-4" (lambda () (interactive) (st-switch '(4))) "switch C-4")
  ("s-5" (lambda () (interactive) (st-switch '(5))) "switch C-5")
  ("s-6" (lambda () (interactive) (st-switch '(6))) "switch C-6")

  ;; switch 2nd from the top
  ("s-a" (lambda () (interactive) (st-switch `(,(nth 0 st-current-space-address) 1))) "switch C-S-1")
  ("s-s" (lambda () (interactive) (st-switch `(,(nth 0 st-current-space-address) 2))) "switch C-S-2")
  ("s-d" (lambda () (interactive) (st-switch `(,(nth 0 st-current-space-address) 3))) "switch C-S-3")
  ("s-f" (lambda () (interactive) (st-switch `(,(nth 0 st-current-space-address) 4))) "switch C-S-4")
  ("s-g" (lambda () (interactive) (st-switch `(,(nth 0 st-current-space-address) 5))) "switch C-S-5"))


(general-define-key
 :keymaps 'override
 "C-c s" 'st-hydra/body

 "s-1" (lambda () (interactive) (st-switch '(1)))
 "s-2" (lambda () (interactive) (st-switch '(2)))
 "s-3" (lambda () (interactive) (st-switch '(3)))
 "s-4" (lambda () (interactive) (st-switch '(4)))
 "s-5" (lambda () (interactive) (st-switch '(5)))
 "s-6" (lambda () (interactive) (st-switch '(6)))

 "s-a" (lambda () (interactive) (st-switch `(,(nth 0 st-current-space-address) 1)))
 "s-s" (lambda () (interactive) (st-switch `(,(nth 0 st-current-space-address) 2)))
 "s-d" (lambda () (interactive) (st-switch `(,(nth 0 st-current-space-address) 3)))
 "s-f" (lambda () (interactive) (st-switch `(,(nth 0 st-current-space-address) 4)))
 "s-g" (lambda () (interactive) (st-switch `(,(nth 0 st-current-space-address) 5)))

 "M-S-<tab>" 'st-switch-space-by-name
 )


;; commit

;; BUG -- saving state of last space not working -- is there a hook
;; for this?  either winner or lower level?  may be easier to patch
;; this as using the hook might require rewriting some of the
;; funcitons

;; tab-like scrolling through current level
;; go to last space -- use history for this, should be very easy
;; pop space to THING and pop buffer to thing (would obviate need to conditionally clear space out)

;; keybindings are using the integer as the name of the workspace, use it as the *position of the workspace*

;; BUG -- when subdividing by using global key for next level, the workspace is effectively lost -- FIX: need to make sure the first workspace in a level does not wipe the other windows...

;; refactor
;; factor the ht access steps into functions to prevent called
;; eval.append everywhere
;; naming a workspace higher in the tree

;; How does this package relate to magneto??

;; WIP global non prefixed keybindings (to replace winds)
;; function clear out all but selected window DONE
;; switch named workspace same level WONT DO
;; switch by name DONE
;; display name DONE
;; reverse sort the workspaces in the modeline string DONE
;; start at 1 for keyboard ergonomics DONE

;; NOTE -- Name is not on the way of describing, but also bookmarking
;; the space.  also gives a flat UI to bookamrks that point antwhere
;; in the tree since you you are presented the completing read in a
;; flat list

;; (yaml-encode st)
;; (yaml-encode st-named-workspaces)

(st-init)
