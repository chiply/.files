;; -*- lexical-binding: t; -*-

;; TODO add time based query to commands, increase limit to something reasonable
;; TODO - projectile integration to allow the commands to work from
;; any buffer and to allow exploring projects if not currently in one

;; code improvements --
;; use jinja for templating the command
;; factor out the commands

;; does comint work in compilation mode?





(defun prepare-for-completing-read (data)
  (-map (lambda (x)
          `(,(mapconcat
              (lambda (x) (if (numberp x) (number-to-string x) x))
              (ht-values x) " ")
            . ,x))
        data))

;; TODO define a function that pulls the value out of alist
(defun completing-read-value (prompt list)
  (let* (
         ;; TODO attempting to stop orderless from re-ordering
         ;;(completion-category-overrides nil)
         ;;(completion-category-defaults nil)
         ;;(completion-styles '(basic))
         (selected-run-key (let ((vertico-sort-function nil)) (completing-read prompt list)))
         (selected-run (alist-get selected-run-key list nil nil 'string=)))
    selected-run))

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
                                  "gh run list --json conclusion,databaseId,displayTitle,event,headBranch,name,startedAt,status,updatedAt,workflowDatabaseId --jq ' [.[] | select(.updatedAt > (now - ( 0.1 * 86400))) ]'")))
         (id (ht-get run "databaseId"))
         ;; todo add osascript
         (cmd (format
               "gh run watch -i 30 %s; osascript -e 'display notification \"%s %s\" with title \"%s 🐙 %s\" sound name \"Frog\"'"
               id
               (ht-get run "displayTitle")
               (concat "on " (ht-get run "headBranch"))
               (projectile-project-name dir)
               (ht-get run "name")))
         )
    ;; vterm
    ;;(let* ((bufnm (format "*GHA: %s 🐙 %s*" (projectile-project-name dir) (ht-get run "name"))))
    ;;(when (get-buffer bufnm)
    ;;(kill-buffer bufnm))
    ;;(let* ((vterm-buffer (save-window-excursion (vterm bufnm)))
    ;;(vterm-process (get-buffer-process vterm-buffer)))
    ;;(process-send-string vterm-process (concat cmd "\n"))
    ;;bufnm
    ;;(zmc-display-output-buffer bufnm 'top 1)))
    ;; compile
    (let* ((bufnm (format "*GHA: %s 🐙 %s*" (projectile-project-name default-directory) (ht-get run "name")))
           (compilation-buffer-name-function
            `(lambda (_) ,bufnm)))
      (save-window-excursion (detached-compile cmd))
      (zmc-display-output-buffer bufnm 'top 1))))

(defun z-gh-run-view-log (dir)
  (let* ((default-directory dir)
         (run (z-gh-pick-run dir "gh run list --json conclusion,databaseId,displayTitle,event,headBranch,name,startedAt,status,updatedAt,workflowDatabaseId --jq ' [.[]| select(.updatedAt > (now-( 30 * 86400)))]'"))
         (id (ht-get run "databaseId"))
         (cmd (format "gh run view %s --log" id)))
    (shell-command cmd)))


;; UI
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
 "g a l" 'z-gh-run-view-log-interact)

