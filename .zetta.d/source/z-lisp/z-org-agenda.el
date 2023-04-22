(require 'org)
(require 'org-agenda)

(advice-add 'org-store-log-note :after 'org-save-all-org-buffers) 
(advice-add 'org-store-log-note :after 'org-agenda-redo) 
(advice-add 'org-agenda-quit :before 'org-save-all-org-buffers)






(setq org-deadline-warning-days 21
      org-log-done 'time
      org-log-into-drawer t
      org-agenda-entry-text-maxlines 50
      org-agenda-span 1
      org-agenda-log-mode-items '(state)
      org-agenda-window-setup 'other-window
      org-agenda-sticky t
      org-agenda-prefix-format '((agenda .  "%i %-12:c%?-12t% s")
                                 (todo .   "  %2c %5e ")
                                 (tags .   "  %2c %5e ")
                                 (search . "  %2c %5e "))

      org-todo-keywords
      '((sequence
         "INBOX(!)"  "REMINDER(!)" "NOTED(!)"  "OPEN(!)"
         "REPETETIVE-TASK(!)" "ASSIGNED(!)" "CLOSED(!)"
         "CANCELLED(@)" "TO-RUN(!)" "RUNNING(!)" "CODING(!)"
         "IDEATING(!)" "IN-REVIEW(!)" "TESTING(!)"  "TODAY(!)"
         "HOLDING(!)"  "SCHEDULED(!)" "RECURRING:MEETING(!)"
         "ATTENDING(!)"  "DEBRIEF(!)"  "INFO-BLOCK(@)"
         "WORK-BLOCK(@)" "SCHEDULE-BLOCK(@)" "TO-LEARN(!)"
         ;; need a done state, even though I'm not ;; need a done state, even though I'm not
         "LEARNING(!)" "|" "foo")
        )
      ;; allows for public and private
      org-archive-location "%s_archive::"
      orgsm-model-code '("INBOX"
                         "REMINDER" "NOTED"
                         "OPEN" "REPETETIVE-TASK" "ASSIGNED"
                         "CLOSED" "CANCELLED" "TO-RUN" "RUNNING"
                         "CODING" "IDEATING" "IN-REVIEW" "TESTING"
                         "TODAY" "HOLDING" "SCHEDULED"
                         "RECURRING:MEETING" "ATTENDING" "DEBRIEF"
                         "INFO-BLOCK" "WORK-BLOCK" "SCHEDULE-BLOCK"
                         "TO-LEARN" "LEARNING")
      org-agenda-custom-commands '(("1" "Simple agenda view"
                                    ;;((org-ql-block
                                    ;;'(or (deadline) (not (path "m_archive")))
                                    ;;((org-ql-block-header "Board"))))
                                    ((tags-todo "*"))
                                    )
                                   ("3" "Agenda"
                                    ((org-agenda-list)))
                                   )
      )

(defun z-org-todo (&optional arg)
  "Todo function to be performed _while on a heading_ in an org
buffer"
  (interactive)
  (let ((st2 (completing-read "Select a state: " orgsm-model-code)))
    (org-todo st2)))

;; interacting with agenda items
(defun z-safe--org-agenda-goto ()
  "Swallows the error caused by org fn trying to split the right
window"
  (interactive)
  (condition-case nil
      (org-agenda-goto nil)
    (error nil)))

(defun z-agenda-org-goto ()
  (interactive)
  (z-safe--org-agenda-goto)
  (org-tree-to-indirect-buffer)
  )

(defun z-agenda-org-todo-alt ()
  (interactive)
  (z-safe--org-agenda-goto)
  ;; note that narrowing is the way to go here - ie not an indirect buffer.  would this be a generally viable alternative to indirect buffer?  see if it becomes necessary
  ;; creating an indirect buffer caused problems with quitting window and preserving
  ;; whatever existed prior to the todo inspection coming up
  (org-toggle-narrow-to-subtree) 
  (let ((inhibit-quit t))
    (if (with-local-quit
          (z-org-todo)
          t)
        ;; if the todo command goes through succesfully
        (progn
          (org-toggle-narrow-to-subtree) 
          (quit-window)
          (z-org-agenda-main)
          )
      (progn
        (org-toggle-narrow-to-subtree) 
        (quit-window)
        (message "trying to cleanup")
        (z-org-agenda-main)
        (setq quit-flag nil)
        )
      )  
    )
  )

(defun z-agenda-org-kill ()
  (interactive)
  (z-safe--org-agenda-goto)
  (org-cut-subtree)
  (org-save-all-org-buffers)
  (quit-window)
  (z-org-agenda-main)
  (org-agenda-redo)
  )


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Changes to builtings
;; trying to avoid this as much as possible, but sometimes it's necessary
(defun org-agenda-priority (&optional force-direction)
  "Set the priority of line at point, also in Org file.
This changes the line at point, all other lines in the agenda referring to
the same tree node, and the headline of the tree node in the Org file.
Called with a universal prefix arg, show the priority instead of setting it."
  (interactive "P")
  (if (equal force-direction '(4))
      (org-show-priority)
    (unless org-enable-priority-commands
      (error "Priority commands are disabled"))
    (org-agenda-check-no-diary)
    (let* ((col (current-column))
           (marker (or (org-get-at-bol 'org-marker)
                       (org-agenda-error)))
           (hdmarker (org-get-at-bol 'org-hd-marker))
           (buffer (marker-buffer hdmarker))
           (pos (marker-position hdmarker))
           (inhibit-read-only t)
           newhead)
      (org-with-remote-undo buffer
        (with-current-buffer buffer
          (widen)
          (goto-char pos)
          (org-show-context 'agenda)
          (funcall 'org-priority force-direction)
          (end-of-line 1)
          (setq newhead (org-get-heading)))
        ;; NOTE I AM REMOVING THIS LINE, PROBABLY SOME ISSUE WITH SUPER AGENDA
        ;;(org-agenda-change-all-lines newhead hdmarker)
        (org-move-to-column col))))
  (org-save-all-org-buffers)
  (org-agenda-redo)
  )

(defun z-agenda-buffer-displayed-p ()
  (interactive)
  (let* ((buffers-being-displayed (-filter
                                   (lambda (x) (z-soda-buffer-displayed-p x))
                                   (buffer-list)))
         (names-of-buffers-being-displayed (-map
                                            (lambda (x) (buffer-name x))
                                            buffers-being-displayed)))
    (if (member "*Org Agenda(1)*" names-of-buffers-being-displayed)
        t
      nil
      )
    )
  )

(defun z-agenda-file-displayed-p ()
  (interactive)
  (let* ((buffers-being-displayed (-filter
                                   (lambda (x) (z-soda-buffer-displayed-p x))
                                   (buffer-list)))
         (names-of-buffers-being-displayed (-map
                                            (lambda (x) (buffer-name x))
                                            buffers-being-displayed)))
    (if (member "agenda.org" names-of-buffers-being-displayed)
        t
      nil
      )
    )
  )

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  Agenda querying







(defun my-kill-other-indirect-bufs ()
  "Kill all indirect buffers other than the current buffer."
  (interactive)
  (dolist (buf  (buffer-list))
    (when (and (buffer-base-buffer buf)  (not (eq (current-buffer) buf)))
      (kill-buffer buf))))

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Hiding
(defun z-hide-all-org ()
  (interactive)
  (let* ((org-buffers-being-displayed
          (-filter
           (lambda (x) (and
                        (z-soda-buffer-displayed-p x) ;; being displayed
                        (window-parameter (get-buffer-window x) 'window-side)
                        (with-current-buffer x
                          (string= major-mode "org-mode"))))
           (buffer-list))))
    (-map (lambda (x) (delete-window (get-buffer-window x))) org-buffers-being-displayed)
    (z-hide-agenda)
    (my-kill-other-indirect-bufs)
    )
  )

(add-to-list 'brushup-styles
             '(progn
                (set-face-attribute 'org-warning nil
                                    :underline nil
                                    :foreground brushup-fg)
                (set-face-attribute 'org-scheduled nil
                                    :foreground brushup-fg-2
                                    :box t
                                    :underline nil)
                (set-face-attribute 'org-scheduled-today nil
                                    :foreground brushup-fg
                                    :underline t
                                    :box t
                                    :weight 'bold)
                (set-face-attribute 'org-scheduled-previously nil
                                    :foreground brushup-fg
                                    :slant 'italic
                                    :underline t)
                (set-face-attribute 'org-upcoming-deadline nil
                                    :foreground brushup-fg
                                    :weight 'bold
                                    :underline t
                                    :slant 'italic
                                    )
                (set-face-attribute 'org-upcoming-distant-deadline nil
                                    :foreground brushup-fg
                                    :slant 'italic
                                    :weight 'bold
                                    )
                (set-face-attribute 'org-link nil
                                    :inherit 'org-tag
                                    :underline t
                                    :box nil
                                    :weight 'bold
                                    )
                )
             )

(z-side "^ \\*Agenda Commands*" 'top 1)
(z-side "^\\*Org Agenda*" 'right)

(evil-set-initial-state 'org-agenda-mode 'normal)

(defhydra+ hydra-org ()
  ("A" z-hide-all-org "Hide all org")
  )

(general-define-key
 :keymaps '(org-mode-map org-agenda-mode-map)
 :states '(normal visual insert)
 ;; two levels of quitting - close the org buffer and return to
 ;; agenda, or close everything
 "C-<return>" '(lambda () (interactive)
                 ;; quit window and open agenda
                 ;; config set up for case when org-roam buffer
                 ;; temporariliy replaces org-agenda buffer
                 ;; needs to be delete-window instead of quit-window, since
                 ;; sometimes, depending on interaction while in roam
                 ;; buffers, the windows to the
                 ;; zettl/node/note/org-roam-file can remain open
                 (save-buffer)
                 (delete-window)
                 (when (z-soda-mode-displayed-p "org-agenda-mode")
                   (z-org-agenda "1" org-super-agenda-groups-main)
                   (org-agenda-redo)
                   )
                 (my-kill-other-indirect-bufs)
                 (select-window z-captured-from-win)
                 )
 "s-q"  'z-hide-all-org

 )

(general-define-key
 ;; need to duplicate for org-super-agenda-header-map
 :states '(normal visual insert)
 :keymaps '(org-agenda-mode-map)
 "q" 'org-agenda-quit
 "r" 'org-agenda-redo
 "S" 'org-save-all-org-buffers
 "gj" 'org-agenda-goto-date
 "gJ" 'org-agenda-clock-goto
 "gm" 'org-agenda-bulk-mark
 "go" 'org-agenda-open-link
 "s" 'org-agenda-schedule
 "+" 'org-agenda-priority-up
 "," 'org-agenda-priority
 "-" 'org-agenda-priority-down
 "y" 'org-agenda-todo-yesterday
 "N" 'org-agenda-add-note
 "u" 'org-agenda-bulk-unmark
 "x" 'org-agenda-exit
 "j"  'org-agenda-next-line
 "k"  'org-agenda-previous-line
 "Vt" 'org-agenda-toggle-time-grid
 "Vw" 'org-agenda-week-view
 "Vl" 'org-agenda-log-mode
 "Vd" 'org-agenda-day-view
 "Vc" 'org-agenda-show-clocking-issues
 ":" 'z-org-roam-agenda-set-tag
 ";" 'org-timer-set-timer
 "I" 'helm-org-task-file-headings
 "Z" 'org-agenda-entry-text-mode
 "<return>" 'z-agenda-org-goto
 "gh" 'org-agenda-holiday
 "gv" 'org-agenda-view-mode-dispatch
 "f" 'org-agenda-later
 "b" 'org-agenda-earlier
 "e" '(lambda ()
        (interactive)
        (condition-case nil
            (org-agenda-set-effort)
          (error nil))
        (org-agenda-redo))
 "n" nil  ; evil-search-next
 "{" 'org-agenda-manipulate-query-add-re
 "}" 'org-agenda-manipulate-query-subtract-re
 "a" 'org-agenda-archive
 "." 'org-agenda-goto-today
 "<" 'org-agenda-filter-by-category
 ">" 'org-agenda-date-prompt
 "F" 'org-agenda-follow-mode
 "D" 'org-agenda-deadline
 "H" 'org-agenda-holidays
 "J" 'org-agenda-next-date-line
 "K" 'org-agenda-previous-date-line
 "L" 'org-agenda-recenter
 "P" 'org-agenda-show-priority
 "R" 'org-agenda-clockreport-mode
 "T" 'org-agenda-show-tags
 "X" 'org-agenda-clock-cancel
 "[" 'org-agenda-manipulate-query-add
 "g\\" 'org-agenda-filter-by-tag-refine
 "]" 'org-agenda-manipulate-query-subtract
 "g/" 'org-agenda-filter-by-tag
 "0" 'evil-digit-argument-or-evil-beginning-of-line
 "t" 'z-agenda-org-todo-alt
 "d" 'z-agenda-org-kill
 )

(general-define-key
 :states '(normal visual)
 :keymaps '(org-mode-map)
 :prefix ","
 "A" 'z-jump-to-agenda-entry
 )

(add-hook
 'org-agenda-mode-hook
 (lambda ()
   (setq-local adaptive-wrap-extra-indent 10)
   (adaptive-wrap-prefix-mode)
   (visual-line-mode)))

(provide 'z-org-agenda)
