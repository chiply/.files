;; -*- lexical-binding: t; -*-

;; TODO:
;; use jinja for templating the command
;; factor out the commands
;; projectile integration

(setq z-gh-list-run-command-for-watch "gh run list --json conclusion,databaseId,displayTitle,event,headBranch,name,startedAt,status,updatedAt,workflowDatabaseId --jq ' [.[] | select(.updatedAt > (now - ( 0.1 * 86400))) ]'")
(setq z-gh-run-watch-command "gh run watch -i 10 %s; osascript -e 'display notification \"%s %s\" with title \"%s 🐙 %s\" sound name \"Frog\"'")
(setq z-gh-list-run-command-for-view "gh run list --json conclusion,databaseId,displayTitle,event,headBranch,name,startedAt,status,updatedAt,workflowDatabaseId --jq ' [.[]| select(.updatedAt > (now-( 30 * 86400)))]'")
(setq z-gh-view-run-command "gh run view %s --log")

(defun completing-read-value (prompt list)
  (let* ((selected-run-key (let ((vertico-sort-function nil)) (completing-read prompt list))))
    (alist-get selected-run-key list nil nil 'string=)))

(defun z-gh-pick-run (dir cmd)
  (interactive)
  (let* ((default-directory dir)
         (json (shell-command-to-string cmd))
         (json-ht (json-parse-string json))
         (runs (z-gh-add-keys-to-record json-ht)))
    (completing-read-value "" runs)))

(defun z-gh-add-keys-to-record (data)
  (-map
   (lambda (x)
     `(,(mapconcat (lambda (x) (if (numberp x) (number-to-string x) x)) (ht-values x) " ")
       . ,x))
   data))

(defun z-gh-run-watch (dir nosleep)
  (interactive)
  (let* ((default-directory dir)
         (run (z-gh-pick-run dir (concat (if nosleep "" "sleep 5 && ") z-gh-list-run-command-for-watch)))
         (cmd (format z-gh-run-watch-command
                      (ht-get run "databaseId")
                      (ht-get run "displayTitle")
                      (concat "on " (ht-get run "headBranch"))
                      (projectile-project-name dir)
                      (ht-get run "name")))
         (bufnm (format "*GHA run: %s 🐙 %s*"
                        (projectile-project-name default-directory)
                        (ht-get run "name")))
         (compilation-buffer-name-function `(lambda (_) ,bufnm)))
    (save-window-excursion (compile cmd))
    ;;(zmc-display-output-buffer bufnm 'top 1)
    (display-buffer bufnm)
    ))

(defun z-gh-run-view-log (dir)
  (let* ((default-directory dir)
         (run (z-gh-pick-run dir z-gh-list-run-command-for-view))
         (id (ht-get run "databaseId"))
         (cmd (format z-gh-view-run-command id))
         (bufnm (format "*GHA log: %s 🐙 %s*"
                        (projectile-project-name default-directory)
                        (ht-get run "name"))))
    (shell-command cmd bufnm)
    ;; run (ansi-color-apply-on-region (point-min) (point-max)) in the bufnm
    (with-current-buffer bufnm
      (ansi-color-apply-on-region (point-min) (point-max)))
    ))


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

