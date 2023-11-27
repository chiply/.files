;; LEFT OFF
;; test persisting (start inicludng wiinds again)
;; actually hold off on persisting... creates otherr complicatoins.... keep the 3-d structure transient forr now, eg don't save across sessionis
;; -- works, refactor winds out of window and invorporate views (not snapshots, that is something separate)... these should be under winds-extras-views-

;; order of the views... should be reversed
;; how to handle renaming, deleting, etc...

;; somewhat accidental, but falls back elegantly for gt at end of tab list, prmopts for swiitch, creates if doesn't exist
;; actually doesn't fallback well!!! fals to restablish current buffer


;; need a wrapper for ad hoc bookmark functioin which selects the bookmark that gets saved.







;;;;;;;;;;;;;;;;;;;;;; Snapshots
(defun z-strip-text-properties (str)
  (let* ((foo    str)
         (start  0)
         (end    (length foo)))
    (set-text-properties start end nil foo)
    foo)
  )

(defun z-get-snapshots ()
  (let ((snapshots (-filter
                    (lambda (bm-view-name) (string-match "snapshot-*" bm-view-name ))
                    (bookmark-view-names)
                    )))
    (when snapshots (-map
                     (lambda (snapshot) (z-strip-text-properties snapshot))
                     snapshots
                     ))
    )
  )

(defun z-delete-snapshots ()
  (interactive)
  (-map
   (lambda (x) (bookmark-view-delete x))
   (z-get-snapshots)
   )
  )


(defun snapshot-lessp (string1 string2)
  (let (
        (string1_number (string-to-number (car (last (split-string string1 "-")))))
        (string2_number (string-to-number (car (last (split-string string2 "-")))))
        )
    (< string1_number string2_number)
    )

  )

(defun z-bookmark-view-generate-snapshot-name ()
  ;; get names
  (let* ((snapshots (z-get-snapshots)))
    ;;(setq snapshots '("snapshot-1" "snapshot-2" "snapshot-11"))
    ;; get the latest name
    (if snapshots
        (progn 
          (setq snapshots-sorted (cl-sort snapshots 'snapshot-lessp))
          (concat
           "snapshot-"
           (number-to-string (+ 1 (string-to-number
                                   (car (last (split-string
                                               (car (last (cl-sort snapshots-sorted 'snapshot-lessp))) "-")))))))
          )
      "snapshot-1"
      )
    )
  )










(tab-bar-mode)


;;;;;;;;;;;;; ws-cfg views
(setq z-ws-cfg-bv-list '(
                         ;; car is ws cfg and cdr is a bookmark view (bv)
                         ((main 1) . ("bv--main-1: default"))
                         ))
(setq z-ws-cfg-bv-current-bv "bv--main-1: default")

(setq z-ws-cfg-bv-leftoff '())

(add-to-list 'desktop-globals-to-save 'z-ws-cfg-bv-list)
(add-to-list 'desktop-globals-to-save 'z-ws-cfg-bv-leftoff)
(add-to-list 'desktop-globals-to-save 'z-ws-cfg-bv-current-bv)


;; create the initional bookmark
;;(z-ws-cfg-bv-new-bv "default")


(defun z-ws-cfg-bvs ()
  (alist-get
   `(,(intern (car (car z-ws-alist))) ,(winds-get-cur-cfg))
   z-ws-cfg-bv-list
   nil nil 'equal)
  )


(defun z-ws-cfg-bv-new-bv (&optional name)
  (interactive)
  ;;;; pre
  ;; save current bookmark
  (bookmark-view-save z-ws-cfg-bv-current-bv)
  ;; rest
  (let* ((name (or name (completing-read "bv name" '())))
         (bvprefix "bv--")
         (bm-full-name (concat bvprefix (car (car z-ws-alist)) "-" (number-to-string (winds-get-cur-cfg)) (format ": %s" name)))
         )
    (bookmark-view-save bm-full-name)
    (setf
     (alist-get
      `(,(intern (car (car z-ws-alist))) ,(winds-get-cur-cfg))
      z-ws-cfg-bv-list
      nil nil 'equal)
     (append
      (alist-get
       `(,(intern (car (car z-ws-alist))) ,(winds-get-cur-cfg))
       z-ws-cfg-bv-list
       nil nil 'equal)
      `(,(concat bvprefix (car (car z-ws-alist)) "-" (number-to-string (winds-get-cur-cfg)) ": " name)))
     )
    (setq z-ws-cfg-b-current-bv bm-full-name)
    )
  )


(defun z-ws-cfg-bv-switch (&optional name)
  (interactive)
  ;; save current buffer state
  (bookmark-view-save z-ws-cfg-bv-current-bv)
  ;; should be switch or create
  (let* ((name (or
                name
                ;; TODO -- should only prompt for ws cfg local 
                (completing-read
                 "select a tab: "
                 (z-ws-cfg-bvs)
                 ;;(-filter
                 ;;(lambda (name) (string-match "^bv--*" name))
                 ;;(bookmark-view-names))
                 )))
         (bvprefix "bv--")
         )
    (if (member name (alist-get
                      `(,(intern (car (car z-ws-alist))) ,(winds-get-cur-cfg))
                      z-ws-cfg-bv-list
                      nil nil 'equal))
        (progn
          ;; switch to the bookmark
          (bookmark-view name)
          (setq z-ws-cfg-bv-current-bv name))
      (progn
        (z-ws-cfg-bv-new-bv name)
        (setq z-ws-cfg-bv-current-bv (concat bvprefix (car (car z-ws-alist)) "-" (number-to-string (winds-get-cur-cfg)) (format ": %s" name)))
        )
      )
    ;;(message "UPDATED")
    ;; force refresh the tab bar
    )
  )

;; need to introduce the notion of a current bookmark... note the leftoff functionality here
;; define update current bookmark

(defun z-propertize-tab-bar-string-tab (str)
  (if (string= str z-ws-cfg-bv-current-bv)
      ;;; ughh... need to modify the text to make the tab bar update
      ;;; immediately... this is an annoyance!  all caps is a good
      ;;; workaround
      (concat (propertize (upcase (nth 1 (split-string str ": "))) 'face 'focus-focused))
    (propertize (nth 1 (split-string str ": ")) 'face 'focus-unfocused)
    )
  )

(defun z-tab-bar-bvs ()
  (let ((ws-cfg-bvs (z-ws-cfg-bvs))) 
    (-filter
     (lambda (x) (member x ws-cfg-bvs))
     (bookmark-view-names)
     )
    ))



;; taken from winds
(defun winds-get-status-msg ()
  "Display a status message in the echo area with the current ws id and cfg id."
  (interactive)
  (let* ((wsids  (sort (winds--get-wsids) #'<))
         (cfgids (sort (winds--get-cfgids) #'<))
         (bg       (face-attribute 'mode-line-inactive :background))
         (sel-fg   (face-attribute 'mode-line :foreground))
         (unsel-fg (face-attribute 'mode-line-inactive :foreground))
         (sel-face   `(:background ,bg :foreground ,sel-fg))
         (unsel-face `(:background ,bg :foreground ,unsel-fg))
         (msg-left (mapcar
                    (lambda (id) (if (eq id (winds-get-cur-ws))
                                     (propertize (format "%s " id) 'face sel-face)
                                   (propertize (format "%s " id) 'face unsel-face)))
                    wsids))
         (msg-right (mapcar
                     (lambda (id) (if (eq id (winds-get-cur-cfg))
                                      (propertize (format " %s" id) 'face sel-face)
                                    (propertize (format " %s" id) 'face unsel-face)))
                     cfgids))
         (msg-left  (cl-reduce #'concat msg-left))
         (msg-right (cl-reduce #'concat msg-right))
         (msg-left  (concat (propertize "W " 'face unsel-face) msg-left))
         (msg-right (concat msg-right (propertize " C" 'face unsel-face))))
    (format "%s|%s" msg-left msg-right)
    ;; Don't spam *Messages*
    ))



;; LEFT OFF - this is why tab bar isn't working
(defun z-tab-bar-string ()
  (concat
   " "
   "{ "
   (winds-get-status-msg)
   ;;(winds-display-status-msg)
   "  "
   "["
   (mapconcat 'z-propertize-tab-bar-string-tab (z-tab-bar-bvs) " | ")
   "]"
   " }"

   ))

(defun z-ws-cfg-bv-switcher (dir)
  (let* (
         (current-index (cl-position z-ws-cfg-bv-current-bv (z-tab-bar-bvs) :test 'equal))
         (previous-index (- current-index 1))
         (next-index (+ current-index 1))
         (previous-tab (nth previous-index (z-tab-bar-bvs)))
         (next-tab (nth next-index (z-tab-bar-bvs)))
         )
    (cond
     ((string= dir "prev") (z-ws-cfg-bv-switch previous-tab))
     ((string= dir "next") (z-ws-cfg-bv-switch next-tab))
     ) 
    ))     

;; works nicely!
(general-define-key
 :keymaps 'override
 :states '(normal visual)
 "gT" (lambda () (interactive) (z-ws-cfg-bv-switcher "prev"))
 "gt" (lambda () (interactive) (z-ws-cfg-bv-switcher "next"))
 "g C-t" (lambda () (interactive) (z-ws-cfg-bv-switch))
 )






(defun zpath ()
  (let ((path (abbreviate-file-name default-directory)))
    (if (> (length path) 30)
        (z-minify-path default-directory)
      path
      )
    ))

(defun zwhitespace () (let ((x " ")) x))

;; (defun z-yaml-json-info ()
;;   (cond
;;    ((or
;;      ;; anything using yaml
;;      (equal major-mode 'docker-compose-mode)
;;      (equal major-mode 'yaml-mode))
;;     (concat "{" (jpt-yaml-path-to-point) "}"))
;;    ((or
;;      (equal major-mode 'jsonian-mode))
;;     (concat "{" (jsons-get-path-python) "}"))
;;    )
;;   )

(defun z-org-outline-path ()
    (when (string= major-mode "org-mode") (concat " > " (org-display-outline-path) "/" (org-get-heading)))
)


;;;; For tab bar
(setq tab-bar-format '(z-tab-bar-string
                       zwhitespace
                       zpath
                       zwhitespace
                       ;;lsp-headerline--build-string
                       ;;z-yaml-json-info
                       z-org-outline-path
                       ;; everything here on will be aligned on the right
                       tab-bar-format-align-right
                       recursion-indicator--string
                       "  "
                       ;;tab-bar-format-global
                       ))










;; the interface to making snapshoots -- using consuot bookmark to access them
(defun z-bookmark-view-snapshot ()
  (interactive)
  (let* ((name (z-bookmark-view-generate-snapshot-name))
         (snapshotname (z-bookmark-view-generate-snapshot-name)))
    (bookmark-view-save snapshotname) 
    ;; fixes strange issue caused by savnig the bookmark
    (bookmark-view snapshotname)
    )
  )




