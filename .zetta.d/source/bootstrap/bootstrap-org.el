(use-package org
  :ensure nil
  :mode ("\\.org" . org-mode)

  :config
  ;; although aesthetically less pleasing, the indent mode can cause
  ;; issues, sometimes text snaps out of indent mode
  (setq-default org-indent-mode nil) ;; NOTE doesn't work?
  (setq org-confirm-babel-evaluate nil
        org-table-convert-region-max-lines 10000
        org-use-fast-todo-selection 'expert
        org-attach-store-link-p 'file
        org-hide-leading-stars nil
        org-archive-location "archive.org::* From %s"
        org-agenda-files '(
                           ;; order matters
                           "~/logseq/graphs/main/pages/emacs.org"
                           "~/logseq/graphs/main/pages/todo.org"
                           )
        org-persist-directory (expand-file-name
                               ".data/org-persist"
                               user-emacs-directory)
        org-id-locations-file (expand-file-name
                               ".data/org/.org-id-locations"
                               user-emacs-directory)
        org-startup-folded (quote nofold) ;; everything but drawers
        org-startup-indented t
        org-refile-use-outline-path 'file
        org-log-refile 'time
        org-log-into-drawer t
        org-outline-path-complete-in-steps nil
        org-refile-allow-creating-parent-nodes 'confirm
        org-refile-targets '((nil :maxlevel . 10) ;; current buf
                             (org-agenda-files :maxlevel . 10))
        org-src-window-setup 'plain
        org-src-lang-modes
        '(("bash" . sh) ("beamer" . latex) ("calc" . fundamental)
          ("emacs-lisp" . emacs-lisp) ("shell" . sh) ("sqlite" . sql)
          ("html" . web) ("js" . js2) ("jsx" . rjsx))
        org-table-shrunk-column-indicator "|"
        ;; these match Plain Org's states as their custom state
        ;; feature doesn't actually work
        org-todo-keywords
        '((sequence
           ;; self-explanatory
           "TODO(t!)"
           ;; in progress, aka 'DOING' 'WORKING ON' 'OPEN'
           "STARTED(s!)"
           ;; waiting on someone else, but still actively being
           ;; worked on.
           "WAITING(w!)" 
           ;; on hold, not actively being worked on or
           ;; with another team with an unknown
           ;; timeline. aka 'BLOCKED'
           "HOLD(h!)"
           ;; things that are high priority to bring
           ;; into the 'TODO' state next. use infrequently
           "NEXT(n!)"
           "|"
           ;; self-explanatory
           "DONE(d!)"
           ;; self-explanatory
           "CANCELLED(c!)"
           ;; use infrequently, different from
           ;; cancelled in that this is something that
           ;; is not necessary any longer due to the
           ;; fact that its purpose is being fulfilled
           ;; by something else.  cancelled is meant to
           ;; capture the cancellation of a task for
           ;; some other reason, whether a
           ;; reprioritization or scope-change
           "OBSOLETE(o!)"
           ))
        )


  (defun orgtree-forward-orgtree (&optional arg)
    "Move ARG times to start of a set of the same orgtree characters."
    (interactive "P")
    (setq arg (or arg 1))
    (if (> arg 0)
        (progn (org-next-visible-heading 1) (point))
      (progn (org-next-visible-heading -1) (point))))

  (defun orgtree-backward-orgtree (&optional arg)
    "Move ARG times to end of a set of the same orgtree characters."
    (interactive "P")
    (orgtree-forward-orgtree (- (or arg 1))))

  (put 'orgtree 'forward-op 'orgtree-forward-orgtree)


  (defun zett-org-get-title (file)
    (let (title)
      (when file
        (with-current-buffer
            (get-file-buffer file)
          (pcase (org-collect-keywords '("TITLE"))
            (`(("TITLE" . ,val))
             (setq title (car val)))))
        (if title
            title
          ""
          ;;(if (string= ((project-name (project-current nil default-directory))) "-")
          ;;file
          ;;((project-name (project-current nil default-directory))))
          ))
      ))

  (defun z-org-open-at-point ()
    (interactive)
    (let ((browse-url-browser-function 'browse-url-default-browser))
      (call-interactively 'org-open-at-point)
      )
    )

  ;; display
  ;; TODO these don't load immediately: fix
  (add-to-list 'org-emphasis-alist '("*" (:foreground "black" :background "yellow")))

  ;; makes visible in focus mode
  ;; defer styling to hl-todo which allows finer grained control inside and outside of headings
  (set-face-attribute 'org-todo nil :foreground nil :background "#FFFFB6B6C1C1")
  (set-face-attribute 'org-done nil :foreground nil :background "pale green")
  (set-face-attribute 'org-level-1 nil :height 1.33 :foreground nil :background 'unspecified)
  (set-face-attribute 'org-level-2 nil :height 1.2 :foreground nil :background 'unspecified)
  (set-face-attribute 'org-level-3 nil :height 1.15 :foreground nil :background 'unspecified)
  (set-face-attribute 'org-level-4 nil :height 1.15 :foreground nil :background 'unspecified)
  (set-face-attribute 'org-level-5 nil :height 1.15 :foreground nil :background 'unspecified)
  (set-face-attribute 'org-level-6 nil :height 1.15 :foreground nil :background 'unspecified)
  (set-face-attribute 'org-level-7 nil :height 1.15 :foreground nil :background 'unspecified)
  (set-face-attribute 'org-level-8 nil :height 1.15 :foreground nil :background 'unspecified)

  (defun z-org-go ()
    (interactive)
    (org-refile '(1)))

  (defun z-org-append ()
    (interactive)
    (org-insert-heading-respect-content)
    (evil-append 1)
    )

  (defun z-org-append-todo ()
    (interactive)
    (org-insert-heading-respect-content)
    (evil-append 1)
    )

  (defun call-z-org-todo-with-prefix ()
    (interactive)
    (let ((current-prefix-arg '(4)))
      (call-interactively 'z-org-todo)
      )
    )

  (defun z-org-call-tangle-with-prefix ()
    (interactive)
    (setq current-prefix-arg '(4))
    (call-interactively 'org-babel-tangle))
  

  :evil
  (evil-set-initial-state 'org-mode 'normal)



  :general
  (
   :keymaps '(org-mode-map)
   "<S-return>" 'org-edit-special
   "C-+" 'org-table-expand
   "C-_" 'org-table-shrink
   "s-j" 'org-next-visible-heading
   "s-k" 'org-previous-visible-heading
   )
  (
   :keymaps '(org-mode-map org-agenda-mode-map)
   "C-c C-S-o" 'z-org-open-at-point
   "C-c C-o" 'org-open-at-point
   )
  (
   ;; TODO make this org-specific -- already tried, but couldn't get
   ;; the keybindings to work
   :keymaps 'menu-org-map
   "g" (** z-org-go)
   "j" (** org-next-visible-heading)
   "k" (** org-previous-visible-heading)
   "U" (** outline-up-heading)
   "J" (** org-move-subtree-down)
   "K" (** org-move-subtree-up)

   "a" (** z-org-append)
   "T" (** z-org-append-todo)
   "8" (** org-toggle-heading)
   "O" (** org-capture)
   "z" (** org-add-note)
   "S" (** org-schedule)
   "D" (** org-deadline)
   "t" (** call-z-org-todo-with-prefix)

   ;; tree structure
   "h" (** org-metaleft)
   "H" (** org-shiftmetaleft)
   "l" (** org-metaright)
   "L" (** org-shiftmetaright)
   "-" (** org-cycle-list-bullet)
   "r" (** org-refile)
   "A" (** org-archive-subtree)
   "s" (** org-sort)
   "q" (** org-columns-quit)
   
   "TAB" (** org-cycle)
   "S-TAB" (** org-global-cycle)
   "i" (** org-tree-to-indirect-buffer)
   "G" (** org-sparse-tree)

   ;; misc
   "m" (** org-mark-element)
   "M" (** org-mark-subtree)
   "C-t" (** z-org-call-tangle-with-prefix)
   "C-S-t" (** org-babel-tangle)
   )

  :hook (
         (org-ctrl-c-ctrl-c-final . org-table-shrink)
         (org-mode . (lambda () (progn
                                  (auto-fill-mode -1)
                                  (org-indent-mode -1)
                                  (visual-line-mode -1)
                                  (toggle-truncate-lines -1) 
                                  )))))

(provide 'bootstrap-org)











