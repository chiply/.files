(use-package origami)


;;(use-package org-bullets
;;:hook (org-mode . (lambda () (org-bullets-mode 1)))
;;)

;; basic tweaks and bindings
(setenv "BROWSER" "chrome")

(use-package org-ql
  :config
  (setq org-ql-view-display-buffer-action
        `(
          (display-buffer-in-side-window)
          (side . top)
          (window-height . 0.20)
          (slot . 1)
          (window-parameters . ((no-delete-other-windows . 1)))
          )
        )
  )


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Flow / tasks

(use-package org-agenda
  :straight nil 

  :config
  (advice-add 'org-store-log-note :after 'org-save-all-org-buffers) 
  (advice-add 'org-store-log-note :after 'org-agenda-redo) 
  (advice-add 'org-agenda-quit :before 'org-save-all-org-buffers)


  (setq org-deadline-warning-days 21
        org-log-done 'time
        org-log-into-drawer t
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
  (defun z-completion-in-agenda-file (&optional arg)
    (interactive "P")
    (let* (
           (title (if (or (string= major-mode 'org-mode) (projectile-project-name))
                      (zett-org-get-title (buffer-file-name))
                    ""))
           (buffer (current-buffer))
           (agenda-file-displayed-p (z-agenda-file-displayed-p))
           )
      (select-window (display-buffer "agenda.org"))
      (let ((inhibit-quit t))
        ;; unfold all log drawers for context
        (progn
          (setq current-prefix-arg '(64))
          (call-interactively 'org-cycle)
          )
        (if (with-local-quit
              (if arg
                  (consult-line "* ")
                (consult-line (concat "* " title " "))) ;; headlines
              (org-tree-to-indirect-buffer) ;; INDIRECT BUFFER
              t)
            (org-hide-drawer-all)
          (progn
            (org-hide-drawer-all)
            (if agenda-file-displayed-p
                nil
              (quit-window))
            (select-window (display-buffer buffer))
            (setq quit-flag nil))))
      )
    )


  (defun z-completion-in-agenda-buffer (&optional arg)
    (interactive "P")
    ;; use of resiters for configuration here
    ;; hides agenda in the event that it wasn't orginally selected
    (let* (
           (title (if (or (string= major-mode 'org-mode) (projectile-project-name))
                      (zett-org-get-title (buffer-file-name))
                    ""))
           (buffer (current-buffer))
           (agenda-buffer-displayed-p (z-agenda-buffer-displayed-p))
           )
      ;; agenda
      (z-org-agenda-main)
      (let ((inhibit-quit t))
        (if (with-local-quit
              (origami-open-all-nodes (current-buffer))
              (if arg
                  (consult-line)
                (consult-line (concat title " "))
                )
              (unless (string-match-p
                       (regexp-quote "CLOSED")
                       (buffer-substring (point-at-bol) (point-at-eol)))
                (org-agenda-redo)
                )
              ;; these two functions are intended to expose the task
              ;; contents WITHOUT selecting it
              (z-agenda-org-goto)
              (z-org-agenda-main)
              t)
            (progn
              (unless (string-match-p
                       (regexp-quote "CLOSED")
                       (buffer-substring (point-at-bol) (point-at-eol)))
                (org-agenda-redo)
                )
              )
          (progn
            ;; addinig this has the affect of closing quitiing the
            ;; agenda file winodw, and if it wasn't already open, side
            ;; window slot 1 if it was opened just for this. WORKS
            (quit-window) 
            ;; ensure we are in the agenda
            (z-org-agenda-main)
            ;; note that the agenda is hooked onto this
            ;; THIS IS TO GET THE ORGIAMI FOLDING TO TAKE AFFECT
            (org-agenda-redo)
            ;; go back to the orginal buffer where capture was called
            (select-window (display-buffer buffer))
            (if agenda-buffer-displayed-p
                nil
              (z-hide-agenda)
              )
            (setq quit-flag nil)))
        )
      ) 
    )



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

  :brushup
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
                  ;;(set-face-attribute 'org-level-1 nil :inherit nil :underline nil)
                  ;;(set-face-attribute 'org-level-2 nil :inherit nil :underline nil)
                  ;;(set-face-attribute 'org-level-3 nil :inherit nil :underline nil)
                  ;;(set-face-attribute 'org-level-4 nil :inherit nil :underline nil)
                  ;;(set-face-attribute 'org-level-5 nil :inherit nil :underline nil)
                  ;;(set-face-attribute 'org-level-6 nil :inherit nil :underline nil)
                  ;;(set-face-attribute 'org-level-7 nil :inherit nil :underline nil)
                  ;;(set-face-attribute 'org-level-8 nil :inherit nil :underline nil)

                  )
               )

  :display
  (z-side "^ \\*Agenda Commands*" 'top 1)
  (z-side "^\\*Org Agenda*" 'right)
  

  :evil
  (evil-set-initial-state 'org-agenda-mode 'normal)



  :hydra
  (defhydra+ hydra-org ()
    ("A" z-hide-all-org "Hide all org")
    )

  :general
  (
   :keymaps 'override
   :states '(normal insert visual)
   ;; note this is borken since it only pulls from 1 file
   "s-Z" 'z-completion-in-agenda-file
   ;; this okay
   "s-z" 'z-completion-in-agenda-buffer
   )
  (
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
  (
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
  (
   :states '(normal visual)
   :keymaps '(org-mode-map)
   :prefix ","
   "A" 'z-jump-to-agenda-entry
   )
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  Super Agenda
(use-package org-super-agenda
  :init
  (setq z-org-super-agenda-auto-show-groups
        '("Inbox"
          "In Mind"
          "Sync"
          "Today"
          "Async"
          "Ready to Run"
          "Open"
          "Upcoming Events"
          "Recurring Meetings"
          "Knowledge Debt"
          "Recurring Tasks"
          "Block"
          "No State"
          "Holding")
        )

  (setq org-super-agenda-groups-main
        '(
          (:name "In Mind" :todo ("REMINDER")) ;; wordplay for 'keep in mind'
          (:name "Sync" :todo ("CODING"
                               "IDEATING"
                               "IN-REVIEW"
                               "ATTENDING"
                               "LEARNING"
                               "DEBRIEF"))
          (:name "Async" :todo ("RUNNING" "TESTING"))
          (:name "Today" :todo ("TODAY"))
          (:name "Block" :todo ("INFO-BLOCK" "WORK-BLOCK" "SCHEDULE-BLOCK"))
          (:name "Ready to Run" :todo ("TO-RUN"))
          (:name "Upcoming Events" :todo ("SCHEDULED"))
          (:name "Open" :todo ("OPEN"))
          (:name "Noted" :todo ("NOTED"))
          (:name "Recurring Tasks" :todo ("REPETETIVE-TASK"))
          (:name "Recurring Meetings" :todo ("RECURRING:MEETING"))
          (:name "Knowledge Debt" :todo ("TO-LEARN"))
          (:name "Assigned" :todo ("ASSIGNED"))
          (:name "Inbox" :todo ("INBOX"))
          (:name "Holding" :todo ("HOLDING"))
          (:name "To Archive" :todo ("CLOSED"))
          ))

  (defun z-org-super-agenda-origami-fold-default ()
    "Fold certain groups by default in Org Super Agenda buffer."
    (when org-super-agenda-groups
      (progn
        (forward-line 2)
        (cl-loop do (origami-forward-toggle-node (current-buffer) (point))
                 while (origami-forward-fold-same-level (current-buffer) (point)))
        (--each z-org-super-agenda-auto-show-groups
          (goto-char (point-min))
          (when (re-search-forward (rx-to-string `(seq bol " " ,it)) nil t)
            (origami-show-node (current-buffer) (point))))
        )
      )
    )

  (defun z-org-agenda (cmd grp)
    "Run org-agenda with the given CMD.  Use groups specified by
GRP.  Note grouping is performed by org-super-agenda if grouping
is provided."
    (if grp
        (let ((org-super-agenda-groups grp)) (org-agenda nil cmd))
      (let ((org-super-agenda-groups nil)) (org-agenda nil cmd))
      )
    ;; set text scale
    ;;(unless (equal text-scale-mode-amount -2) (text-scale-set -2))
    )

  ;; common enough that I'm making it's own function
  (defun z-org-agenda-main ()
    (interactive)
    (z-org-agenda "1" org-super-agenda-groups-main))

  (defun z-refresh-agenda ()
    "Activates the agenda, refreshes it.  Cursor should remain
where is was when z-refresh-agenda was called"
    (interactive)
    (save-selected-window
      (z-org-agenda-main)
      (org-agenda-redo)
      )
    (message "AGENDA REFRESHED")
    )

  (defun z-hide-agenda ()
    (interactive)
    (z-org-agenda-main)
    (org-agenda-quit)
    ;; this restores the point to where it was when the function was called
    )

  (defun z-highlight-agenda ()
    (interactive)
    ;; web link
    (highlight-regexp "\\[\\[https.*?\\]\\]" 'modus-themes-nuanced-blue)
    ;; roam / org link (unfortunately there is no distinction here)
    (highlight-regexp "\\[\\[id.*?\\]\\]" 'modus-themes-nuanced-green)
    ;; file link
    (highlight-regexp "\\[\\[file.*?\\]\\]" 'modus-themes-nuanced-red)

    ;; headers
    (highlight-regexp "Block" 'modus-themes-nuanced-red)
    (highlight-regexp "Sync" 'modus-themes-refine-green)
    (highlight-regexp "Async" 'modus-themes-nuanced-green)
    )


  (org-super-agenda-mode)

  :brushup
  (add-to-list 'brushup-styles
               '(progn
                  (set-face-attribute 'org-super-agenda-header nil
                                      :underline nil
                                      :overline nil
                                      :extend t
                                      :box nil
                                      :foreground brushup-fg-3
                                      :weight 'bold
                                      )
                  )
               )


  :hydra
  (defhydra+ hydra-run ()
    ("a" z-org-agenda-main "Org Agenda")
    )


  :general
  (
   :keymaps '(org-super-agenda-header-map)
   "j"  nil
   "k"  nil
   "g" nil
   "G" nil
   "," nil
   "/" nil
   "C" nil
   "c" nil
   "<tab>" nil
   )
  (
   :states '(normal visual insert)
   :keymaps '( org-agenda-mode-map org-super-agenda-header-map  )
   "vt" '(lambda () (interactive)
           (z-org-agenda "1" org-super-agenda-groups-main))
   "vT" '(lambda () (interactive)
           (z-org-agenda "2" nil))
   "va" '(lambda () (interactive)
           (z-org-agenda "3" nil))
   )
  (
   :keymaps '(org-super-agenda-header-map)
   "<tab>" 'origami-toggle-node
   )

  :hook ((org-agenda-mode . origami-mode)
         (org-agenda-finalize . z-org-super-agenda-origami-fold-default)
         (org-agenda-finalize . z-highlight-agenda)
         )
  )


(use-package org-capture
  :straight nil

  :init
  (setq org-capture-templates
        '(
          ;; LEFT OFF - can keep this around, but make another for public-- captal should be public
          ;;(
          ;;"H" "Linked header"
          ;;entry
          ;;(file "~/.files/org-roam/agenda.org")
           ;;;; note using custom function from above
           ;;;; can refine thiis... But for now it's a dumb link to the originial file.  org-roam processes this since
           ;;;; the target is an org-roam directory
          ;;"* INBOX %(if (file-exists-p (zett-org-get-title (org-capture-get :original-file))) \"\" \"[[file:%(abbreviate-file-name (org-capture-get :original-file))][%(zett-org-get-title (org-capture-get :original-file))]] \") :: %?\n"
          ;;:prepend t
          ;;) 
          (
           "h" "private"
           entry
           (file "~/.files/org-roam/daily/agenda.org")
           ;; note using custom function from above
           "* INBOX %?"
           :prepend t
           )
          (
           "H" "Unlinked header"
           entry
           (file "~/.files/org-roam/daily/agenda_pub.org")
           ;; note using custom function from above
           "* INBOX %?"
           :prepend t
           )
          )
        )

  ;;:hook (org-capture-after-finalize . z-refresh-agenda)
  )

;; export backends
(require 'ox-beamer)
(use-package epresent)
(use-package ox-reveal
  :config
  (setq org-reveal-root "https://cdnjs.cloudflare.com/ajax/libs/reveal.js/3.6.0/"
        org-reveal-mathjax t)
  )
(use-package htmlize )
(use-package ox-jekyll-md)


;; convenient super bindinigs for organization
(setq z-captured-from-win "")
(general-define-key 
 :kemaps 'override
 :states '(normal visual insert)
 "s-t" '(lambda () (interactive)
          (setq z-captured-from-win (selected-window))
          (org-capture nil "h")
          (org-set-property "received" (format-time-string "%Y-%m-%d %a %H:%M"))
          (org-id-get-create)
          )
 "s-T" '(lambda () (interactive)
          (setq z-captured-from-win (selected-window))
          (org-capture nil "H")
          (org-set-property "received" (format-time-string "%Y-%m-%d %a %H:%M"))
          (org-id-get-create)
          )
 )

;; note order matters here as there is overlap between org
;; roam and org-mode (org-roam is in org mode, but it matches
;; for this first, so it displays in slot 2, not slot 1)
(z-side "^\\*org-roa*" 'right 2 0.20 0.30)












;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; org roam
(use-package org-roam
  :init
  (setq org-roam-directory (file-truename "~/.files/org-roam"))
  (setq org-roam-db-location (expand-file-name ".data/org-roam/org-roam.db" user-emacs-directory))
  (setq org-roam-v2-ack t)

  :config
  (org-roam-db-autosync-mode)
  (setq org-roam-completion-everywhere t)

  (defun z-org-roam-node-find ()
    (interactive)
    (setq z-captured-from-win (selected-window))
    (org-roam-node-find))

  (defun z-org-roam-capture () (interactive)
         (setq z-captured-from-win (selected-window))
         (org-roam-capture))


  (defun z-get-header-from-link (s)
    (interactive)
    (nth 0 (split-string
            (nth 3 (split-string s "\\["))
            "]"
            )))
  (defun ndk/link-fast-copy ()
    (interactive)
    (let* ((context (org-element-context))
           (type (org-element-type context))
           (beg (org-element-property :begin context))
           (end (org-element-property :end context)))
      (when (eq type 'link)

        (z-get-header-from-link
         (buffer-substring beg end)
         )

        )))

  (defun z-jump-to-agenda-entry (&optional noselect)
    (interactive)
    ;; agenda command (from lambda)
    (let ((buf (current-buffer))
          (re (concat (ndk/link-fast-copy) "$"))
          )

      (progn
        (z-org-agenda "1" org-super-agenda-groups-main)
        (org-agenda-redo)
        )

      ;; insert from ndk
      (or
       (search-forward-regexp re nil t)
       (search-backward-regexp re nil t)
       )
      ;;(z-agenda-org-goto)

      (if noselect
          (select-window (get-buffer-window buf))
        (progn
          (z-org-agenda "1" org-super-agenda-groups-main)
          (org-agenda-redo)
          )
        )


      )
    )
  

  :general 
  (
   :keymaps 'override
   "s-o" 'z-org-roam-node-find
   "s-O" 'z-org-roam-capture
   "s-i" 'org-roam-node-insert
   )
  )

(use-package org-roam-ui
  :init
  (setq org-roam-ui-sync-theme t
        org-roam-ui-follow t
        org-roam-ui-update-on-save t
        org-roam-ui-open-on-start t))



(use-package org-roam-timestamps
  :init
  (org-roam-timestamps-mode)
  (setq org-roam-timestamps-parent-file t)
  (setq org-roam-timestamps-remember-timestamps t)
  (setq org-roam-timestamps-minimum-gap 30)
  )


(defun z-org-roam-list-node-titles ()
  (interactive)
  (-map (lambda (x) `(,(org-roam-node-title x))) (org-roam-node-list))
  )

(defun z-org-roam-agenda-set-tag ()
  (interactive)
  (org-agenda-set-tags (replace-regexp-in-string
                        "-" "_"
                        (replace-regexp-in-string
                         " " "_"
                         (completing-read "org-roam " (z-org-roam-list-node-titles)))))
  (org-agenda-redo)
  )




















;;;;;;;;;;;;;;;;; Literature management
(z-side "bibliography.bib" 'right 2 0.30)

(use-package org-ref
  :demand t
  :config
  (setq org-ref-insert-cite-function
      (lambda ()
	(org-cite-insert nil)))
  (require 'bibtex)

  (setq bibtex-completion-bibliography '("~/.files/.lit/bibliography.bib")
        bibtex-completion-library-path '("~/.files/.lit/pdf/")
        bibtex-completion-notes-path "~/.files/org-roam/"
        bibtex-completion-notes-template-multiple-files "* ${author-or-editor}, ${title}, ${journal}, (${year}) :${=type=}: \n\nSee [[cite:&${=key=}]]\n"

        bibtex-completion-additional-search-fields '(keywords)
        ;;bibtex-completion-display-formats
        ;;'((article       . "${=has-pdf=:1}${=has-note=:1} ${year:4} ${author:36} ${title:*} ${journal:40}")
        ;;(inbook        . "${=has-pdf=:1}${=has-note=:1} ${year:4} ${author:36} ${title:*} Chapter ${chapter:32}")
        ;;(incollection  . "${=has-pdf=:1}${=has-note=:1} ${year:4} ${author:36} ${title:*} ${booktitle:40}")
        ;;(inproceedings . "${=has-pdf=:1}${=has-note=:1} ${year:4} ${author:36} ${title:*} ${booktitle:40}")
        ;;(t             . "${=has-pdf=:1}${=has-note=:1} ${year:4} ${author:36} ${title:*}"))
        bibtex-completion-pdf-open-function 'find-file
        )

  (setq bibtex-autokey-year-length 4
        bibtex-autokey-name-year-separator "-"
        bibtex-autokey-year-title-separator "-"
        bibtex-autokey-titleword-separator "-"
        bibtex-autokey-titlewords 2
        bibtex-autokey-titlewords-stretch 1
        bibtex-autokey-titleword-length 5
        )

  :general
  (
   :states '(insert normal visual)
   :keymaps '(override)
   "s-u" 'org-ref-bibtex-hydra/body
   )
  )

;; (use-package ivy
;;   :config
;;   :general
;;   (
;;    :keymaps 'ivy-minibuffer-map
;;    "C-j" 'ivy-next-line
;;    "C-k" 'ivy-previous-line
;;    "M-S-<" 'ivy-beginning-of-buffer
;;    "M-S->" 'ivy-end-of-buffer
;;    )
;;   )

;;(use-package ivy-bibtex :demand t)
;;(require 'org-ref-ivy)

(setq org-ref-insert-link-function 'org-ref-insert-link-hydra/body
      ;;org-ref-insert-cite-function 'org-ref-cite-insert-ivy
      org-ref-insert-label-function 'org-ref-insert-label-link
      org-ref-insert-ref-function 'org-ref-insert-ref-link
      org-ref-cite-onclick-function (lambda (_) (org-ref-citation-hydra/body)))

(use-package biblio
  :config
  (setq biblio-download-directory "~/.files/.lit/pdf/")
  )





(use-package org-noter
  :config
  (setq org-noter-always-create-frame nil)
  (setq org-noter-kill-frame-at-session-end nil)
  (setq org-noter-notes-search-path'("~/.files/org-roam"))
  ;; Your org-noter config ........
  )

(use-package pdf-tools
  :config
  (pdf-tools-install)

  :display
  
  (z-side "pdf-occur-buffer-mode" 'left 1)
  (z-side "^\\*Outline*" 'left 3)

  :general
  (
   :keymaps '(pdf-view-mode-map)
   :states '(normal insert)
   "C-S-j" 'pdf-view-next-page
   "C-S-k" 'pdf-view-previous-page
   )

  )

;;(use-package pdf-continuous-scroll-mode
;;:straight (pdf-continuous-scroll-mode :type git :host github :repo "dalanicolai/pdf-continuous-scroll-mode.el")
;;
;;:general
;;(
;;:keymaps '(pdf-view-mode-map)
;;:states '(normal insert)
;;"C-j" 'pdf-continuous-scroll-forward
;;"C-k" 'pdf-continuous-scroll-backward
;;)
;;
;;:hook (pdf-view-mode . pdf-continuous-scroll-mode)
;;
;;)

(use-package org-pdftools
  :hook (org-mode . org-pdftools-setup-link))

(use-package org-noter-pdftools
  :after org-noter
  :config
  ;; Add a function to ensure precise note is inserted
  (defun org-noter-pdftools-insert-precise-note (&optional toggle-no-questions)
    (interactive "P")
    (org-noter--with-valid-session
     (let ((org-noter-insert-note-no-questions (if toggle-no-questions
                                                   (not org-noter-insert-note-no-questions)
                                                 org-noter-insert-note-no-questions))
           (org-pdftools-use-isearch-link t)
           (org-pdftools-use-freestyle-annot t))
       (org-noter-insert-note (org-noter--get-precise-info)))))

  ;; fix https://github.com/weirdNox/org-noter/pull/93/commits/f8349ae7575e599f375de1be6be2d0d5de4e6cbf
  (defun org-noter-set-start-location (&optional arg)
    "When opening a session with this document, go to the current location.
With a prefix ARG, remove start location."
    (interactive "P")
    (org-noter--with-valid-session
     (let ((inhibit-read-only t)
           (ast (org-noter--parse-root))
           (location (org-noter--doc-approx-location (when (called-interactively-p 'any) 'interactive))))
       (with-current-buffer (org-noter--session-notes-buffer session)
         (org-with-wide-buffer
          (goto-char (org-element-property :begin ast))
          (if arg
              (org-entry-delete nil org-noter-property-note-location)
            (org-entry-put nil org-noter-property-note-location
                           (org-noter--pretty-print-location location))))))))
  (with-eval-after-load 'pdf-annot
    (add-hook 'pdf-annot-activate-handler-functions #'org-noter-pdftools-jump-to-note)))



(use-package org-pdfview)

;; (use-package org-roam-bibtex
;;   :config
;;   (require 'ivy-bibtex)
;;   (setq orb-note-actions-interface 'hydra)
;;   (org-roam-bibtex-mode)
;;   :custom
;;   (orb-insert-interface 'ivy-bibtex)
;;   )

;; (straight-use-package '(consult-bibtex :host github
;;                                        :repo "mohkale/consult-bibtex"))



;; LEFT OFF-- making progress with org roam
;; TODO: delete garbage notes

;; orb-note-actions from within a bibliographic note: can open pdf, prompt for download pdf, switch to pdf ;; add pdf to lib: from org-roam buffer or bibtex buffer

;; consult-bibtex-edit-notes, will create a roam node, works from anywhere which is nice... these notes would be for any bibtex entry.  So this is like, edt or create org-roam node for bibtex entry
;; org-ref-open-bibtex-notes works on an entry in the bibtex buffer;; creates file if not exists

;; once you have the node, you can look at downloading the pdf... 
;; add pdf to library - how is the association made -- it is heurstic based

;; note the org-ref-- stuff works in a bib buffer, but not in an org roam buffer. 
;; should bind pdf to c-return and notes to retrun or something... these are 2 of the more convenient functions

;; TODO -- 
;; LEFT OFF - still figurin out full workflow...  still accounting for rest of web, eg books w/out dois, webpages, but the answer to that is likely org-roam based using roam-refs... that's fine as those links would lead to 



;;(use-package org-transclusion)







(defun gpc/open-node-roam-ref-url ()
  "Open the URL in this node's ROAM_REFS property, if one exists"
  (interactive)
  (when-let ((ref-url (org-entry-get-with-inheritance "ROAM_REFS")))
    (browse-url ref-url)))


(defun gpc/open-node-roam-ref-url-eww ()
  "Open the URL in this node's ROAM_REFS property, if one exists"
  (interactive)
  (when-let ((ref-url (org-entry-get-with-inheritance "ROAM_REFS")))
    (eww-browse-url ref-url)))


(add-hook 'org-mode-hook (lambda () (font-lock-add-keywords
                                     nil
                                     '(("^-\\{5,\\}"  0 '(:foreground "red" :weight bold))))))



(setq org-id-link-to-org-use-id t)


(setq org-time-stamp-formats
      '("<%Y-%m-%d %a>" . "<%Y-%m-%d %a %H:%M:%S>"))













;; fropm https://emacs.stackexchange.com/questions/42471/how-to-export-markdown-from-org-mode-with-syntax
(org-export-define-derived-backend 'mymd 'md
  :menu-entry
  '(?y "Export to My Markdown"
       ((?M "To temporary buffer"
            (lambda (a s v b) (org-mymd-export-as-markdown a s v)))
        (?m "To file" (lambda (a s v b) (org-mymd-export-to-markdown a s v)))
        (?o "To file and open"
            (lambda (a s v b)
              (if a (org-mymd-export-to-markdown t s v)
                (org-open-file (org-mymd-export-to-markdown nil s v)))))))
  :translate-alist '((example-block . org-mymd-example-block)
                     (fixed-width . org-mymd-example-block)
                     (src-block . org-mymd-example-block)))

(defun org-mymd-example-block (example-block _content info)
  "Transcode element EXAMPLE-BLOCK as ```lang ...'''."
  (format "```%s\n%s\n```"
          (org-element-property :language example-block)
          (org-remove-indentation
           (org-export-format-code-default example-block info))))

;;;###autoload
(defun org-mymd-export-as-markdown (&optional async subtreep visible-only)
  "See `org-md-export-as-markdown'."
  (interactive)
  (org-export-to-buffer 'mymd "*Org My MD Export*"
    async subtreep visible-only nil nil (lambda () (text-mode))))

;;;###autoload
(defun org-mymd-convert-region-to-md ()
  "See `org-md-convert-region-to-md'."
  (interactive)
  (org-export-replace-region-by 'mymd))

;;;###autoload
(defun org-mymd-export-to-markdown (&optional async subtreep visible-only)
  "See `org-md-export-to-markdown'."
  (interactive)
  (let ((outfile (org-export-output-file-name ".md" subtreep)))
    (org-export-to-file 'mymd outfile async subtreep visible-only)))

;;;###autoload
(defun org-mymd-publish-to-md (plist filename pub-dir)
  "Analogous to `org-md-publish-to-md'."
  (org-publish-org-to 'mymd filename ".md" plist pub-dir))




(setq org-pandoc-options-for-markdown '((wrap . none)))






(use-package org-modern
  :config
  (setq org-modern-table nil)
  :hook (org-mode . (lambda ()
                      (org-indent-mode -1)
                      (org-modern-mode 1)))
  )

;; not ready for primetime yet
;; (use-package org-rainbow-tags
;;   :straight (:host github :repo "KaratasFurkan/org-rainbow-tags")
;;   :custom
;;   (org-rainbow-tags-extra-face-attributes
;;    ;; Default is '(:weight 'bold)
;;    '(:inverse-video t :box t :weight 'bold))
;;   :hook
;;   (org-mode . org-rainbow-tags-mode))



