;;; z-org-super-agenda.el --- Extensions for org-super-agenda -*- lexical-binding: t -*-


;;; Code:
(require 'org)
(require 'org-agenda)
(require 'org-super-agenda)


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
        (:name "In Mind" :todo ("REMINDER"))
        (:name "Sync" :todo ("CODING" "IDEATING" "IN-REVIEW" "ATTENDING" "LEARNING" "DEBRIEF"))
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
;;;###autoload
(defun z-org-agenda-main ()
  (interactive)
  (z-org-agenda "1" org-super-agenda-groups-main))

;;;###autoload
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

;;;###autoload
(defun z-hide-agenda ()
  (interactive)
  (z-org-agenda-main)
  (org-agenda-quit)
  ;; this restores the point to where it was when the function was called
  )

;;;###autoload
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


(defhydra+ hydra-run ()
  ("a" z-org-agenda-main "Org Agenda")
  )


(general-define-key
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

(general-define-key
 :states '(normal visual insert)
 :keymaps '( org-agenda-mode-map org-super-agenda-header-map  )
 "vt" '(lambda () (interactive)
         (z-org-agenda "1" org-super-agenda-groups-main))
 "vT" '(lambda () (interactive)
         (z-org-agenda "2" nil))
 "va" '(lambda () (interactive)
         (z-org-agenda "3" nil))
 )

(general-define-key
 :keymaps '(org-super-agenda-header-map)
 "<tab>" 'origami-toggle-node
 )

(add-hook 'org-agenda-mode-hook 'origami-mode)
(add-hook 'org-agenda-finalize-hook 'z-org-super-agenda-origami-fold-default)
(add-hook 'org-agenda-finalize-hook 'z-highlight-agenda)


(provide 'z-org-super-agenda)
;;; z-org-super-agenda.el ends here
