
;; -*- lexical-binding: t; -*-


;; TODO add time based query to commands, increase limit to something reasonable

;; loose framework
;; retrieve json via some lisp function -- simplest form is shell-command-to-string using some cli as long as this outputs json, but could alternatively be using an API or even some other program.  the key is that the output is json.  note that if the raw payload has the entries nested or if the output needs to be manipulated to make is useful, this can be done with jq or some other tool.
;; making the payloads from the API requests or the CLI commands as useful as possible is the key to scoping that complexity out of elisp and keeping the elisp methods as simple as possible. this is a key design principle.
;; this json then gets processed for use in an emacs workflow.  these are almost always -- 1. grab a list 2. present for selection and allow user to select 3. do something with the selection.  This process involves simply rendering the contents of each record in the JSON payload into a string that can be used for completion.  If there is no unqiue key in the payload, one should be added

(defun prepare-for-completing-read (data)
  (-map (lambda (x)
          `(,(mapconcat
              (lambda (x) (if (numberp x) (number-to-string x) x))
              (ht-values x) " ")
            . ,x))
        data))


;; todo define a function that pulls the value out of alist
(defun completing-read-value (prompt list)
  (let* (
         ;; TODO attempting to stop orderless from re-ordering
         (completion-category-overrides nil)
         (completion-category-defaults nil)
         (completion-styles '(basic))
         (selected-run-key (let ((vertico-sort-function nil)) (completing-read prompt list)))
         (selected-run (alist-get selected-run-key list nil nil 'string=)))
    selected-run))


;; TODO need to always inject an index into the list as so I can use something as an id to pull the value out of runs
;; this should be very short sequence of characters
(defun z-gh-pick-run (dir cmd)
  (interactive)
  (let* (;; TODO have projectile prompt for a project or use the default
         (default-directory dir)
         ;; run the command
         (json (shell-command-to-string cmd))
         (json-ht (json-parse-string json))
         ;; LEFT OFF TODO SORT -- can't get this to work
         ;; (json-ht (-sort (lambda (a b) (< (ht-get a "updatedAt") (ht-get b "updatedAt"))) json-ht))
         (runs (prepare-for-completing-read json-ht)))
    (completing-read-value "" runs)))

(defun z-gh-run-watch (dir nosleep)
  (interactive)
  (let* ((default-directory dir)
         (run (z-gh-pick-run dir (concat
                                  (if nosleep "" "sleep 5 && ")
                                  "gh run list -s in_progress --json conclusion,databaseId,displayTitle,event,headBranch,name,startedAt,status,updatedAt,workflowDatabaseId --jq ' [.[] | select(.updatedAt > (now - ( 30 * 86400)))]'")))
         (id (ht-get run "databaseId"))
         ;; todo add osascript
         (cmd (format
               "gh run watch %s; osascript -e 'display notification \"%s %s\" with title \"%s 🐙 %s\" sound name \"Frog\"'"
               id
               (ht-get run "displayTitle")
               (concat "on " (ht-get run "headBranch"))
               (projectile-project-name dir)
               (ht-get run "name")
               )))
    (let* ((bufnm (format "*GHA: %s 🐙 %s*" (projectile-project-name dir) (ht-get run "name"))))
      (when (get-buffer bufnm)
        (kill-buffer bufnm))
      (let* ((vterm-buffer (save-window-excursion (vterm bufnm)))
             (vterm-process (get-buffer-process vterm-buffer)))
        (process-send-string vterm-process (concat cmd "\n"))
        bufnm
        (zmc-display-output-buffer bufnm 'top 1)))))

(defun z-gh-run-view-log (dir)
  (let* ((default-directory dir)
         (run (z-gh-pick-run dir "gh run list --json conclusion,databaseId,displayTitle,event,headBranch,name,startedAt,status,updatedAt,workflowDatabaseId --jq ' [.[]| select(.updatedAt > (now-( 30 * 86400)))]'"))
         (id (ht-get run "databaseId"))
         (cmd (format "gh run view %s --log" id)))
    (shell-command cmd)))


;;;; to be executed from magit
;; add an optional argument C-u 
(defun z-gh-run-watch-interact (&optional arg)
  (interactive "P")
  (z-gh-run-watch default-directory arg))

(defun z-gh-run-view-log-interact ()
  (interactive)
  (z-gh-run-view-log default-directory))

(general-define-key
 :states '(normal visual)
 :keymaps 'magit-mode-map
 "g a w" 'z-gh-run-watch-interact
 "g a l" 'z-gh-run-view-log-interact
 )

