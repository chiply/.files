;; add some text to the top hyah

;; create a nested hashtable using ht
(require 'ht)


(defvar st) ;; the ht representing the space tree
(defvar st-current-space-address) ;; the address of the current space
(defvar st-spaces) ;; the ht that stores the spaces
(defvar st-history '()) ;; the history of the spaces
(defvar st-named-workspaces (ht-create))


;; Basically the option is to use either the built-in window
;; configuration switching functions, or to use bookmark for
;; you. Bookmark view allows for the same buffer to be displayed in
;; multiple spaces but with cursor different positions. The built-ins
;; however do not support this, if you move cursor in a buffer in one
;; workspace it will actually move the cursor to the same position in
;; a different workspace. The trade on for this is that workspace
;; switching significantly faster, and Emacs seems to hang a little
;; bit less one restoring window configurations complicated. For me
;; using the built-in is a fair trade off because it's pretty rare
;; that I'm gonna be displaying the same buffer in multiple work
;; spaces, even when I do I'm typically not trying to preserve the
;; Kirshner location in both, although that probably would be my ideal
;; default setting.  Another words and very very minor and rarely used
;; feature for having multiple cursor positions for a given buffer
;; across workspaces is absolutely not worth the trade-off in snappy
;; Ness of workspace switching.  Interestingly I have no idea why
;; bookmark he was in much more slow operation than the built-in but
;; that's probably worth investingating.
;; The difference in performance is actually kind of drastic using the
;; built-in you get basically instantaneous switching for even
;; complicated window layouts that are probably more cramped and I
;; would practically use. However at the same and even lower levels of
;; complexity using bookmark view it can take one and a half to two
;; seconds to switch fully I am not a fan of that to me that's way way
;; way too much of a slow down to enable a pretty esoteric behavior
;; that I'm probably never going to leverage


;; generate a uuid
(defun uuidgen ()
  (interactive)
  (string-trim (shell-command-to-string "uuidgen")))


(defun st-history-match (history sublist)
  (let ((n (length sublist)))
    (car (-filter
          (lambda (x) (equal (butlast x (- (length x) n)) sublist))
          history))))

(defun st-number-of-spaces-current-level ()
  (length
   (ht-keys
    (eval (append
           '(ht-get* st "spacetree")
           (butlast st-current-space-address))))))


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
    (ht-set st-spaces address (current-window-configuration))
    (setq st-history (cons st-current-space-address st-history))
    ;; only if this isn't the first space, empty it out (this prevents
    ;; workspaces from being lost during subdivision, basically forces
    ;; the higher level workspace prior to subdivision to be saved)
    (when (> (st-number-of-spaces-current-level) 1)
      (st-delete-other-windows-and-switch-to-scratch))
    code))


(defun st-init ()
  (interactive)
  (setq st (ht-create))
  (setq st-spaces (ht-create))
  (setq st-named-workspaces (ht-create))
  (setq st-history '())
  (ht-set st "spacetree" (ht-create))
  (st-add-workspace '(1))
  (force-mode-line-update))


(defun st-switch (new-address)
  (interactive)
  (let* ((old-address st-current-space-address)
         (workspace (ht-get st-spaces new-address)))
    (ht-set st-spaces old-address (current-window-configuration))
    (cond ((not workspace)
           (st-add-workspace new-address))
          ((st-history-match st-history new-address)
           (set-window-configuration (ht-get st-spaces (st-history-match st-history new-address)))
           (setq st-current-space-address (st-history-match st-history new-address)
                 st-history (cons st-current-space-address st-history)))
          (t
           (set-window-configuration (ht-get st-spaces new-address))
           (setq st-current-space-address new-address
                 st-history (cons st-current-space-address st-history)))))
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
                         (let* ((workspace-name (ht-get st-named-workspaces (append level-address `(,x))))
                                (_string (if workspace-name workspace-name (number-to-string x))))
                           (if (equal x level-space)
                               ;; need to change text to update modeline
                               (propertize (concat _string "* ") 'face 'bold)
                             (concat _string " "))))
                       ;; sort (ht-keys node) in ascending order
                       (sort (ht-keys node) (lambda (a b) (< a b)))
                       )
            "| ")))))
    (setq modeline-string (substring modeline-string 0 -2))
    (concat "{ " modeline-string "}")))



(defun st-go-to-last-space ()
  (interactive)
  (st-switch (nth 1 st-history)))


(defun st-go-right ()
  (interactive)
  ;; this is the address up to the last point
  (let ((i (+ 1 (car (last st-current-space-address)))))
    (when (<= i (st-number-of-spaces-current-level))
      (st-switch-current-level i))
    (when (= i (+ 1 (st-number-of-spaces-current-level)))
      (st-switch-current-level 1))
    ))

(defun st-go-left ()
  (interactive)
  (let ((i (- (car (last st-current-space-address)) 1)))
    (when (>= i 1) (st-switch-current-level i))
    (when (= i 0) (st-switch-current-level (st-number-of-spaces-current-level)))
    ))



;;;; UI
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
 "M-<tab>" 'st-go-to-last-space

 "C-<tab>" 'st-go-right
 "C-S-<tab>" 'st-go-left)

;; new-top-level

;; refactor ;; factor the ht access steps into functions to prevent
;; called ;; eval.append everywhere

;; naming a workspace higher in the tree

;; pop space to THING and pop buffer to thing (would obviate need to
;; conditionally clear space out)


;; actually implement a history so we can go not just to the last
;; workspace but traverse through the history



;; How does this package relate to magneto??

;; WIP global non prefixed keybindings (to replace winds)
;; cut out bookmark view DONE
;; go to last space -- use history for this, should be very easy DONE
;; tab-like scrolling through current level DONE
;; function clear out all but selected window DONE
;; switch named workspace same level WONT DO
;; switch by name DONE
;; display name DONE
;; reverse sort the workspaces in the modeline string DONE
;; start at 1 for keyboard ergonomics DONE

;; BUG -- saving state of last space not working -- is there a hook
;; for this?  either winner or lower level?  may be easier to patch
;; this as using the hook might require rewriting some of the
;; funcitons -- This was to do with bookmark you or rather to do with
;; not using bookmark view, turns out window configuration doesn't
;; save the points in the current buffer, I'm not sure why that says,
;; but switching to bookmark for you seem to fix this issue. I wonder
;; if this is going to slow things down performance wise to what I was
;; saying coming out would be a shame butI can leave that dor an
;; optimiztion.  So migrated from winner to bookmark-view. DONE

;; keybindings are using the integer as the name of the workspace, use
;; it as the *position of the workspace*... actually just sorted the
;; list -- this ends up being a good default setting, keeping things
;; positional.  will hold off on implementing the ability to move
;; things around DONE

;; BUG -- when subdividing by using global key for next level, the
;; workspace is effectively lost -- FIX: need to make sure the first
;; workspace in a level does not wipe the other windows... DONE


;; NOTE -- Name is not on the way of describing, but also bookmarking
;; the space.  also gives a flat UI to bookamrks that point antwhere
;; in the tree since you you are presented the completing read in a
;; flat list

;; (yaml-encode st)
;; (yaml-encode st-named-workspaces)

;; edge case -- whatt about if a buffer is deleted in another window

(st-init)

