(use-package compat :ensure nil :demand t)

(use-package magit
  :init
  (setq magit-branch-read-upstream-first 'fallback)
  ;; TODO change
  ;;(setq magit-process-popup-time -1)

  (defun z-magit-project ()
    (interactive)
    (let ((dir (completing-read "Project: " (project-known-project-roots))))
      (magit-status dir)))

  (setq magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1)

  :config
  ;; project.el
  (keymap-substitute project-prefix-map #'project-vc-dir #'magit)
  (cl-nsubstitute-if
   '(magit "magit")
   (pcase-lambda (`(,cmd _)) (eq cmd #'project-vc-dir))
   project-switch-commands)

  ;;(require 'magit-margin)
  (require 'magit-section)

  ;;(setq magit-log-margin-show-shortstat t)
  ;;(setq magit-status-margin '(t age-abbreviated magit-log-margin-width nil 6))
  ;;(setq magit-log-margin '(t age-abbreviated magit-log-margin-width nil 6))
  ;;(add-hook 'magit-status-mode-hook 'magit-toggle-log-margin-style)
  ;;(add-hook 'magit-log-mode-hook 'magit-toggle-log-margin-style)

  (general-unbind :keymaps 'magit-status-mode-map :states 'normal "M-<tab>")
  (general-unbind :keymaps 'magit-mode-map :states 'normal "M-<tab>")
  (general-unbind :keymaps 'magit-section-mode-map :states 'normal "M-<tab>")

  (general-unbind :keymaps 'magit-status-mode-map :states 'normal "C-<tab>")
  (general-unbind :keymaps 'magit-mode-map :states 'normal "C-<tab>")
  (general-unbind :keymaps 'magit-section-mode-map :states 'normal "C-<tab>")

  ;; overriding here -- basically not setting to width of shortstat as
  ;; that ends up cutting off the margin value for forge data
  ;;(defhydra+ hydra-magit ()
  ;;("g" magit-status :exit t)
  ;;("B" magit-branch :exit t)
  ;;("b" magit-blame :exit t)
  ;;("t" magit-tag :exit t)
  ;;("s" magit-stage :exit t)
  ;;("S" magit-stage-modified :exit t)
  ;;("p" magit-push :exit t)
  ;;("c" magit-commit :exit t)
  ;;("l" magit-log :exit t)
  ;;("r" magit-show-refs :exit t)
  ;;("d" vc-diff :exit t)
  ;;("f" magit-fetch :exit t)
  ;;("p" magit-pull :exit t))

  ;;:display
  ;;;;(z-side "\\magit-status-mode" 'right 0)
  ;;(z-side "\\magit-diff-mode" 'right 2)
  ;;;;(z-side "\\magit-log-mode" 'right 1)
  ;;;;(z-side "\\magit-refs-mode" 'right 1)
  ;;;;(z-side "\\magit-revision-mode" 'right 2)


  (general-define-key
   :keymaps 'menu-vc-keymap
   "g" 'magit-status
   "B" 'magit-branch
   "b" 'magit-blame
   "t" 'magit-tag
   "s" 'magit-stage
   "S" 'magit-stage-modified
   "p" 'magit-push
   "c" 'magit-commit
   "l" 'magit-log
   "r" 'magit-show-refs
   "d" 'vc-diff
   "f" 'magit-fetch
   "p" 'magit-pull
   )
  (general-define-key
   :keymaps 'launch-map
   "g" 'menu-vc-keymap
   "G" 'z-magit-project
   )
  (general-define-key
   :keymaps 'text-mode-map
   "C-<return>" 'with-editor-finish
   ) 
  (general-define-key
   :keymaps '(magit-status-mode-map magit-process-mode-map)
   "C-<tab>" 'tab-line-switch-to-next-tab
   "C-S-<tab>" 'tab-line-switch-to-prev-tab
   "M-S-<tab>" 'st-switch-space-by-name
   "M-<tab>" 'st-go-to-last-space
   )

  (setq z-gh-list-run-command-for-watch "gh run list --json conclusion,databaseId,displayTitle,event,headBranch,name,startedAt,status,updatedAt,workflowDatabaseId --jq ' [.[] | select(.updatedAt > (now - ( 0.1 * 86400))) ]'")
  (setq z-gh-run-watch-command "gh run watch -i 10 %s; osascript -e 'display notification \"%s %s\" with title \"%s || %s\" sound name \"Frog\"'")
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
                        (project-name (project-current nil default-directory))
                        (ht-get run "name")))
           (bufnm (format "*GHA run: %s || %s*"
                          (project-name (project-current nil default-directory))
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
           (bufnm (format "*GHA log: %s || %s*"
                          (project-name (project-current nil default-directory))
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



  )

