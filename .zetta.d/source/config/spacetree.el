;;; space-tree.el --- A library for managing spaces -*- lexical-binding: t -*-
;; Copyright 2024 Charlie Holland
;;
;; Author: Charlie Holland <mister.chiply@gmail.com>
;; Maintainer: Charlie Holland <mister.chiply@gmail.com>
;; URL: **
;; Version: 0.0.1
;; Package-Requires: ht, dash

;;; Commentary:
;;
;; space-tree is a library for managing spaces in Emacs. It is inspired
;; by the concept of "workspaces" supported in the most major
;; operating systems' window managers, and is intended to be a
;; lightweight, but flexible alternative to packages tab-bar-mode and
;; eyebrowse.

;; The main features of space-tree are:

;; - A tree-based structure (AKA the space-tree) for organizing
;;   spaces, with branches of mixed and arbitrary depth
;; - A modeline indicator(s) for the current space and context in the
;;   space-tree
;; - Commands for creating and managing spaces

;; space-tree is in the early stages of development and is not yet
;; feature-complete. It is not yet recommended for general use.

;; NOTES:
;; -- Name is not on the way of describing, but also bookmarking the
;; space.  also gives a flat UI to bookamrks that point antwhere in
;; the tree since you you are presented the completing read in a flat
;; list
;; -- Builtin faster than bookmark-view, minor tradeoff in having
;; isolated points for a buffer across spaces
;; -- BUG (FIXED): when splitting from a side window I get an error that actually
;; corrupts the whole window display system; first hypothesis is that
;; this has something to do with the function that empties the new
;; workspace... may need to make this switch to a non side window
;; (there will be at least 1) after the window conf is saved, and THEN
;; -- NOTE This is a note on being able to use some thing like
;; -- perspective in order to save state. Or purchasing state in
;; -- general. And then the related problem which is that space tree
;; -- is essentially just offering a way to switch to or to manage
;; -- work spaces in a hierarchical fashion. But it doesn't do is
;; -- offer a backend for creating andSaving and loading work
;; -- spaces. Right now it's using the default, but it could just as
;; -- easily be unit using winter mode to save and restore. You could
;; -- just as easily be using bookmark – view, it could just as easily
;; -- be using perspective. Which brings it full circle basicallyWhen
;; -- considering switching to perspective to get persistent workspace
;; -- configurations, one possible and probably the most viable
;; -- solution is to simply abstract away the function being used to
;; -- save and restore the window configuration.


;; TODO:
;; pop existing-space to THING and pop buffer to thing (would obviate
;; need to conditionally clear existing-space out)
;; remove name
;; keybindings for insert mode (need to use keychord)
;; actually implement a history feature with recent-space-list so we can go not just to the last
;; forwards and backwards create a space if it doesn't exist -- change this
;; last workpace, but by level, not by overall
;; document edge case -- whatt about if a buffer is deleted in another window
;; How does this package relate to magneto??  add magneto support eg switch to gitproject, but do so in a new space
;; desktop persistance -- possible there are too many unwritable things could be a fools errand.... if we are going to try, it should be using bookmarks


;;; Code:


;; Dependencies
(require 'ht)
(require 'dash)


;; State
(defvar st-tree (ht-create)
  "A nested hashtable that represents the structural layout of the
spaces in a hierarchy (aka a tree).")

(defvar st-current-address '()
  "A list of numbers that represents the address of the current
existing-space in st-tree.")

(defvar st-address-wconf-tbl (ht-create)
  "A hashtable that stores window configurations for each space. The
keys are the addresses of the spaces and the values are the
window configurations.") 

(defvar st-recent-space-list '()
  "A list of the addresses of the most recently visited spaces. The
most recently visited existing-space is at the head of the list.")

(defvar st-space-name-tbl (ht-create)
  "A hashtable that stores names for each space. The keys are the
addresses of the spaces and the values are the names.")

(defvar st-copied-space nil
  "A variable to store copied window configurations.")





;; Customizations
(defcustom st-start-at-0 nil
  "If non-nil, the first space will be numbered 0. Otherwise, the
first space will be numbered 1.")





;; Utilities
(defun st-window-state-put-safely (space)
  "Switches to workspace, ignores 'Selecting deleted buffer' error"
  (let ((result (condition-case _ (window-state-put space) (error _))))
    (when (string= "Selecting deleted buffer" (cadr result))
      (message "Space contains deleted buffers"))))


(defun st-side-window-p ()
  "Returns t if the current window is a side window, nil otherwise."
  (window-parameter (selected-window) 'window-slot))


(defun st-select-non-side-window ()
  "Selects a non-side window. If there are no non-side windows, an
error is thrown."
  (when (st-side-window-p)
    (let ((num-windows (length (window-list))))
      (dotimes (i num-windows)
        (when (st-side-window-p)
          (progn
            (other-window 1)
            (when (not (st-side-window-p))
              (return)))))
      (when (st-side-window-p) (error "No non-side windows found")))))


(defun st-delete-other-windows-and-switch-to-scratch ()
  "Utility function to delete all windows except the current one and
switch to *scratch* buffer.  This is a means of create a clean
slate, typically for a new space."
  (delete-other-windows)
  (switch-to-buffer (get-buffer-create "*scratch*")))

;; check if lista starts with listb.  for example, (st-list-starts-with '(1 2) '(1 2 3)) returns t
(defun st-list-starts-with (lista listb)
  "Returns t if lista starts with listb, nil otherwise."
  (equal (butlast lista (- (length lista) (length listb))) listb))

;; remove duplicates only if they are adjacent in a list
(defun st-remove-adjacent-duplicates (lst)
  "Removes adjacent duplicates from the list LST."
  (let ((result '()))
    (dolist (x lst)
      (if (not (equal x (car result)))
          (setq result (cons x result))))
    (nreverse result)))




;; Analyzing state
(defun st-recent-space-on-path (sublist)
  "Returns the first element (a list) of HISTORY that begins with
sublist. If no such element exists, returns nil."
  (let ((n (length sublist)))
    (car (-filter
          (lambda (x) (equal (butlast x (- (length x) n)) sublist))
          st-recent-space-list))))

(defun st-current-depth ()
  "Returns the depth of the current space in the st-tree."
  (length st-current-address))

(defun st-number-of-spaces-current-level ()
  "Returns the number of spaces at the current level of the st-tree."
  (length (ht-keys (st-get-parent-ht-at st-current-address))))

(defun st-current-parent ()
  "Returns the address of the parent of the current space."
  (butlast st-current-address))

(defun st-space-exists-p (address)
  "Returns t if the space at the given address exists, nil otherwise."
  (member address (ht-keys st-address-wconf-tbl)))



;; Mutating state
;; st-get and st-get-parent-ht-at and st-set are specialized variants of
;; ht-get and ht-set which are reused in space-tree functions for
;; easily accessing and modifying the state in the nested hastable
;; `st-tree`.
(defun st-get (address)
  "Returns the existing-space at the address ADDRESS in the st-tree.
Returns nil if the existing-space doesn't exist."
  (eval (append '(ht-get* st-tree "space-tree") address)))


(defun st-get-parent-ht-at (address)
  "Returns the parent of the existing-space at the address ADDRESS in"
  ;; the filter accoutns for the fact that the address may be 1 level,
  ;; eg it may not have a parent
  (eval (-filter
         (lambda (x) x)
         (append '(ht-get* st-tree "space-tree") (butlast address)))))


(defun st-set (address)
  "Sets the address at the address ADDRESS in the st-tree to"
  (eval (append
         '(ht-set)
         `(,(st-get-parent-ht-at address))
         (last address)
         `(,(ht-create)))))


(defun st-remove (address)
  "Sets the address at the address ADDRESS in the st-tree to"
  (eval (append ;; remove the space from st-tree
         '(ht-remove)
         `(,(st-get-parent-ht-at address))
         (last address)))
  (ht-remove st-space-name-tbl address)
  (ht-remove st-address-wconf-tbl address)
  (setq
   st-recent-space-list
   (-remove
    (lambda (x) (equal x address))
    st-recent-space-list))
  (st-process-history)
  (force-mode-line-update))


(defun st-process-history ()
  "Removes any sublist in st-recent-space-list that is the prefix of
another sublist in st-recent-space-list."
  (setq st-recent-space-list
        (st-remove-adjacent-duplicates
         (-remove
          (lambda (sublista)
            (-filter
             (lambda (sublistb)
               (and
                (> (length sublistb) (length sublista))
                (st-list-starts-with sublistb sublista)))
             st-recent-space-list))
          st-recent-space-list))))


(defun st-create-space-at (address)
  "Adds a existing-space to the st-tree at the address ADDRESS. "
  (st-select-non-side-window)
  (st-set address)
  (setq st-current-address address)
  (ht-set st-address-wconf-tbl address (window-state-get))
  (setq st-recent-space-list (cons st-current-address st-recent-space-list))
  ;; process list -- remove duplicates and branch nodes
  (st-process-history)
  (when (> (st-number-of-spaces-current-level) 1)
    (st-delete-other-windows-and-switch-to-scratch)))


(defun st-name-current-space (name)
  "Names the current space, prompting the user for a name."
  (interactive "sName: ")
  (ht-set st-space-name-tbl st-current-address name)
  (force-mode-line-update))


(defun st-name-space-by-digit-arg (arg)
  "Names the current space, prompting the user for a name."
  (interactive "P")
  (let* ((arg-string (number-to-string arg))
         (address (if (string-match-p "0" arg-string)
                      (split-string arg-string "0")
                    (-filter
                     (lambda (x) (> (length x) 0))
                     (string-split arg-string ""))))
         (address (-map (lambda (x) (string-to-number x)) address)))
    (ht-set st-space-name-tbl address (completing-read "Name: " nil)))
  (force-mode-line-update))




;; Modeline
(defun st-modeline-string-for-level (parent-address level spaces-this-level-ht)
  "Returns a string to be used in the modeline for the given level of
st-tree"
  (mapconcat
   (lambda (space-number)
     (let ((space-name-or-number (or (ht-get
                                      st-space-name-tbl
                                      (append parent-address `(,space-number)))
                                     (number-to-string space-number))))
       (concat ""
               (if (equal space-number level)
                   ;; need to change text to update modeline
                   (propertize (concat space-name-or-number "' ") 'face 'bold)
                 (concat space-name-or-number " "))
               )))
   (sort (ht-keys spaces-this-level-ht) (lambda (a b) (< a b)))))


(defun st-modeline-lighter ()
  "Returns a string to be used as the modeline lighter for space-tree.
This is a critical UI element for space-tree, as it provides a visual
indication of the current space in st-tree, which can grow to be quite
large."
  (setq modeline-string "")
  (dotimes (i (st-current-depth))
    (let* ((parent-address (butlast st-current-address (- (st-current-depth) i)))
           (selected-space-this-level (nth i st-current-address))
           (spaces-this-level-ht (st-get parent-address))
           ;; spaces-this-level-ht should be non-empty
           ;; TODO -- the let vars can go into the helper function above
           (modeline-string-this-node (st-modeline-string-for-level
                                       parent-address
                                       selected-space-this-level
                                       spaces-this-level-ht))
           (modeline-string-to-this-level (concat
                                           modeline-string
                                           modeline-string-this-node
                                           "| ")))
      (setq modeline-string modeline-string-to-this-level)))
  (concat "{ " (substring modeline-string 0 -2) "}"))





;; UI
;; these are all interactive functions that will be used directly, or
;; configured into some KUI by the user.
(defun st-init ()
  "Initializes space-tree. Can also be used to reset space-tree."
  (interactive)
  (let ((first-space-number (if st-start-at-0 0 1)))
    (setq st-tree (ht-create)
          st-address-wconf-tbl (ht-create)
          st-space-name-tbl (ht-create)
          st-recent-space-list '())
    (ht-set st-tree "space-tree" (ht-create))
    (st-create-space-at `(,first-space-number)))
  (force-mode-line-update))

(defun st-save-current-space ()
  "Saves the current window configuration in the st-address-wconf-tbl
at the current address."
  (ht-set st-address-wconf-tbl st-current-address (window-state-get)))


(defun st-switch (address &optional no-update-wconf)
  "Switches to the existing-space at the address ADDRESS."
  (st-select-non-side-window)
  (let ((recent-space (ht-get st-address-wconf-tbl address)))
    (unless no-update-wconf
      (let ((result (condition-case _
                        (window-state-put recent-space)
                      (error _))))
        (when (string= "Selecting deleted buffer" (cadr result))
          ;; TODO (nice to have) implement buffer restoration
          (message "Space contains deleted buffers"))))
    (setq st-current-address address
          st-recent-space-list (cons st-current-address st-recent-space-list))))

;; switch (or create) space
(defun st-switch-or-create (new-address)
  "Switches to the existing space indicated by new-address, or creates
it if it doesn't exist.  This is the workhorse for navigating the
space-tree."
  (interactive)
  (let* ((existing-space (ht-get st-address-wconf-tbl new-address))
         (st-recent-space-address (st-recent-space-on-path new-address)))
    ;; save the current window configuration, the one being switched from
    (st-save-current-space)
    ;; switch to the new existing-space
    (cond
     ;; IF new-address hasn't been visited yet, THEN create it
     ((not existing-space) (st-create-space-at new-address))
     ;; IF new-address points to a recent space or parent, THEN switch to it
     (st-recent-space-address (st-switch st-recent-space-address))))
  ;; update the modeline
  (force-mode-line-update))


(defun st-create-space-current-level ()
  "Adds a new space at the current level of the st-tree."
  (interactive)
  (let* ((parent (st-current-parent))
         (tbl (st-get parent))
         (next-level-number (+ 1 (apply 'max (ht-keys tbl)))))
    (st-create-space-at (append parent `(,next-level-number)))))


(defun st-create-space-top-level ()
  "Adds a new space at the top level of the st-tree."
  (interactive)
  (st-create-space-at
   `(,(+ 1 (apply 'max (ht-keys (ht-get st-tree "spacetree")))))))


(defun st-delete-space (address)
  "Deletes the space at the given address.  If the space is the only
space at its level, it is deleted and the parent space is selected.
Otherwise, the space is deleted and the next space at the same level
is selected."
  (let ((n-spaces (st-number-of-spaces-current-level)))
    (cond ((> n-spaces 1) (st-go-left) (st-remove address))
          ((and (= 1 n-spaces) (= (st-current-depth) 1))
           (error "Cannot delete the only space"))
          ((= 1 n-spaces)
           (st-switch (butlast address) t)
           (st-remove address)))))


(defun st-copy-workspace ()
  "Copies the current workspace to the clipboard."
  (interactive)
  (setq st-copied-space (window-state-get)))


(defun st-paste-workspace (&optional inplace)
  "Pastes the copied workspace to the current space.  If INPLACE is
non-nil, the current space is overwritten with the copied space.  If
INPLACE is nil, a new space is created and the copied space is pasted
there.  If no space has been copied, an error is raised."
  (interactive)
  (when (not st-copied-workspace) (error "no copied space"))
  (when inplace (st-create-space-current-level))
  (st-window-state-put-safely st-copied-workspace))


(defun st-switch-current-level (arg)
  "Switches to the ith space at the current level of the st-tree."
  (interactive "P")
  ;; TODO -- if user doesn't supply arg, ask them for one?  might be
  ;; convenient to have this on both sides of the gt keybinding
  (let ((n (when (not arg)
             (string-to-number
              (read-from-minibuffer "Switch to space: ")))))
    (if n
        ;; TODO -- automatic minibuffer exit
        (st-switch-or-create (append (st-current-parent) `(,n)))
      (st-switch-or-create (append (st-current-parent) `(,arg))))))


(defun st-switch-space-by-digit-arg (arg)
  (interactive "P")
  (let* ((arg-string (if (not arg)
                         (read-from-minibuffer "Switch to space: ")
                       (number-to-string arg)))
         (address (if (string-match-p "0" arg-string)
                      (split-string arg-string "0")
                    (-filter
                     (lambda (x) (> (length x) 0))
                     (string-split arg-string ""))))
         (address (-map (lambda (x) (string-to-number x)) address)))
    (st-switch-or-create address)))


(defun st-switch-space-by-name ()
  "Switches to a named space. Prompts the user to select from a
list of named spaces."
  (interactive)
  (let* ((st-named-spaces-reversed
          (-map
           (lambda (x) `(,(cdr x) . (,(car x))))
           (ht-to-alist st-space-name-tbl)))
         (name (completing-read
                "Select a named space: "
                st-named-spaces-reversed))
         (address (car
                   (ht-get
                    (ht-from-alist st-named-spaces-reversed)
                    name))))
    (st-switch-or-create address)))


(defun st-go-to-last-space ()
  "Switches to the most recently visited space, as recorded by
st-recent-space-list."
  (interactive)
  (st-switch-or-create (nth 1 st-recent-space-list)))


(defun st-go-right ()
  "Switches to the next space to the right at the current level of the
st-tree."
  (interactive)
  ;; this is the address up to the last point
  (let* ((spaces-current-level (sort
                                (ht-keys (st-get (butlast st-current-address)))
                                (lambda (a b) (< a b))))
         (current-position (-elem-index
                            (car (last st-current-address))
                            spaces-current-level))
         (target-position (+ 1 current-position)))
    (if (>= target-position (st-number-of-spaces-current-level))
        (st-switch-current-level (car spaces-current-level))
      (st-switch-current-level (nth target-position spaces-current-level)))))


(defun st-go-left ()
  "Switches to the next space to the left at the current level of
the st-tree."
  (interactive)
  (let* ((spaces-current-level (sort
                                (ht-keys (st-get (butlast st-current-address)))
                                (lambda (a b) (< a b))))
         (current-position (-elem-index
                            (car (last st-current-address))
                            spaces-current-level))
         (target-position (- current-position 1)))
    (if (< target-position 0)
        (st-switch-current-level (car (last spaces-current-level)))
      (st-switch-current-level (nth target-position spaces-current-level)))))


;; START Config

;; KUI Keyboard User Interface (KUI)... note this is all in config --
;; this will be part of the README,but not part of the package

(general-define-key

 ;; TODO macro for these
 ;; top level
 "s-1" (lambda () (interactive) (st-switch-or-create '(1)))
 "s-2" (lambda () (interactive) (st-switch-or-create '(2)))
 "s-3" (lambda () (interactive) (st-switch-or-create '(3)))
 "s-4" (lambda () (interactive) (st-switch-or-create '(4)))
 "s-5" (lambda () (interactive) (st-switch-or-create '(5)))

 ;; second from top level
 "s-a" (lambda () (interactive) (st-switch-or-create `(,(nth 0 st-current-address) 1)))
 "s-s" (lambda () (interactive) (st-switch-or-create `(,(nth 0 st-current-address) 2)))
 "s-d" (lambda () (interactive) (st-switch-or-create `(,(nth 0 st-current-address) 3)))
 "s-f" (lambda () (interactive) (st-switch-or-create `(,(nth 0 st-current-address) 4)))
 "s-g" (lambda () (interactive) (st-switch-or-create `(,(nth 0 st-current-address) 5)))

 ;; third from top level
 "s-A" (lambda () (interactive) (st-switch-or-create `(,(nth 0 st-current-address) ,(nth 1 st-current-address) 1)))
 "s-S" (lambda () (interactive) (st-switch-or-create `(,(nth 0 st-current-address) ,(nth 1 st-current-address) 2)))
 "s-D" (lambda () (interactive) (st-switch-or-create `(,(nth 0 st-current-address) ,(nth 1 st-current-address) 3)))
 "s-F" (lambda () (interactive) (st-switch-or-create `(,(nth 0 st-current-address) ,(nth 1 st-current-address) 4)))
 "s-G" (lambda () (interactive) (st-switch-or-create `(,(nth 0 st-current-address) ,(nth 1 st-current-address) 5)))

 ;; etc... but likely impractical after 3 dimensions

 ;; ergonomics from winds
 "M-S-<tab>" 'st-switch-space-by-name
 "M-<tab>" 'st-go-to-last-space

 ;; ergonomics from tab line, but this overwrites the tab-line, should
 ;; have a better one for this
 "C-M-<tab>" 'st-go-right
 "C-M-S-<tab>" 'st-go-left

 "s-_" (lambda () (interactive) (st-delete-space st-current-address)))


;; TODO use s-t for this as these can't really be used in insert mode
(general-define-key
 :states '(normal visual)
 :keymaps 'override
 "gt" 'st-switch-current-level
 "gT" 'st-switch-space-by-digit-arg
 "g+" 'st-create-space-top-level
 "gn" 'st-create-space-current-level
 )


;; init -- move to config
(st-init)

;; END Config

(provide 'space-tree)
;;; space-tree.el ends here

