(use-package org
  :straight (org :type git :host github :repo "bzg/org-mode")
  :demand t

  :mode ("\\.org" . org-mode)

  :config
  (setq org-confirm-babel-evaluate nil
        org-agenda-files '(
                           ;; order matters
                           "~/.files/org-roam/daily/sprint.org"
                           "~/.files/org-roam/daily/agenda.org"
                           "~/.files/org-roam/daily/agenda_pub.org"
                           )
        org-persist-directory (expand-file-name ".data/org-persist" user-emacs-directory)
        org-id-locations-file (expand-file-name ".data/org/.org-id-locations" user-emacs-directory)
        org-hide-leading-stars t
        org-startup-folded (quote overview)
        org-startup-indented t
        org-refile-use-outline-path 'file
        org-log-refile 'time
        org-outline-path-complete-in-steps nil
        org-refile-allow-creating-parent-nodes 'confirm
        org-refile-targets '((nil :maxlevel . 10) ;; current buf
                             (org-agenda-files :maxlevel . 10))
        org-src-window-setup 'plain
        org-src-lang-modes '(("bash" . sh) ("beamer" . latex) ("calc" . fundamental)
                             ("emacs-lisp" . emacs-lisp) ("shell" . sh) ("sqlite" . sql)
                             ("html" . web) ("js" . js2) ("jsx" . rjsx)
                             )
        )




  (org-babel-do-load-languages
   'org-babel-load-languages
   '(
     (python . t) (emacs-lisp . t) (sql . t)
     (C . t) (sqlite . t) (js . t)
     (ditaa . t) (dot . t)
     (shell . t ) (latex . t )
     )
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
          ;;(if (string= (projectile-project-name) "-")
          ;;file
          ;;(projectile-project-name))
          ))
      ))

  (defun z-org-open-at-point ()
    (interactive)
    (let ((browse-url-browser-function 'browse-url-default-browser))
      (call-interactively 'org-open-at-point)
      )
    )




  ;; display
  (add-to-list 'org-emphasis-alist '("*" (:foreground "black" :background "yellow")))

  :display
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; display related (advice)
;;;;;;;;;;;; ORG STUFF
  (setq suppress-delete-other-windows nil)
  ;; replaces switch to buffer other window
  (setq replace-org-switch-to-buffer-other-window nil)

  (defun z-enable-org-settings ()
    (setq suppress-delete-other-windows t)
    (setq replace-org-switch-to-buffer-other-window t)
    )

  (defun z-disable-org-settings ()
    (setq suppress-delete-other-windows nil)
    (setq replace-org-switch-to-buffer-other-window nil)
    )

  (advice-add 'delete-other-windows :around
              '(lambda (orig-fun &rest args)
                 (unless suppress-delete-other-windows
                   (apply orig-fun args))))

  (advice-add 'org-switch-to-buffer-other-window
              :around
              '(lambda (orig-fun &rest args)
                 (if replace-org-switch-to-buffer-other-window
                     (let* ((buf (get-buffer-create (nth 0 args))))
                       (display-buffer buf)
                       (select-window (get-buffer-window buf))
                       (current-buffer))
                   (apply orig-fun args)
                   )
                 )
              )

  ;; probably better ti write as lets, in case the function doesn't run
  ;; all the way to completion!!!
  (advice-add 'org-agenda
              :before
              '(lambda (&optional arg org-keys restriction) (z-enable-org-settings)))
  (advice-add 'org-agenda
              :after
              '(lambda (&optional arg org-keys restriction) (z-disable-org-settings)))

  (advice-add 'org-add-log-note
              :before
              '(lambda (&optional _purpose) (z-enable-org-settings)))
  (advice-add 'org-add-log-note
              :after
              '(lambda (&optional _purpose) (z-disable-org-settings)))

  (advice-add 'org-capture
              :before
              '(lambda (&optional goto keys) (z-enable-org-settings)))
  (advice-add 'org-capture
              :after
              '(lambda (&optional goto keys) (z-disable-org-settings)))

  (advice-add 'org-export-dispatch
              :before
              '(lambda (&optional goto keys) (z-enable-org-settings)))
  (advice-add 'org-export-dispatch
              :after
              '(lambda (&optional goto keys) (z-disable-org-settings)))


  (advice-add 'kill-this-buffer :after '(lambda () (z-disable-org-settings)))
  (advice-add 'org-capture-kill :after '(lambda () (z-disable-org-settings)))
  (advice-add 'save-buffer :after '(lambda (&optional arg) (z-disable-org-settings)))

  ;; display buffer stuff
  (z-side "^ \\*Org todo*" 'top)
  (z-side "^\\*Org Note*" 'top)
  (z-side "^\\*Org Select*" 'top 2 0.20 0.30)
  (z-side "^\\*Org Export Dispatcher*" 'right)
  (z-side "^\\*Org Src*" 'right)
  (z-side "org-mode" 'right 1)
  (z-side "^\\*Org-Babel Error*" 'right 2)




  :brushup
  (add-to-list 'brushup-styles
               '(progn
                  (set-face-attribute 'org-todo nil
                                      :foreground brushup-bg-4
                                      :background brushup-bg
                                      :height 0.8
                                      :box nil
                                      :underline nil)
                  (set-face-attribute 'org-done nil
                                      :foreground brushup-bg-3
                                      :underline `(:color ,brushup-fg-3))
                  (set-face-attribute 'org-hide nil
                                      :foreground brushup-bg
                                      :background brushup-bg)
                  (set-face-attribute 'org-default nil)
                  (set-face-attribute 'org-date nil
                                      :underline nil)
                  (set-face-attribute 'org-tag nil
                                      :underline nil
                                      :box nil
                                      :height 1.0
                                      :inherit nil
                                      )
                  (set-face-attribute 'org-column nil
                                      :background brushup-bg
                                      )

                  (set-face-attribute 'org-column-title nil
                                      :background brushup-bg
                                      :foreground brushup-bg
                                      )
                  ;; org babel blocks
                  (set-face-attribute 'org-block nil
                                      :background brushup-bg
                                      :extend t
                                      )
                  (set-face-attribute 'org-block-begin-line nil
                                      :foreground brushup-fg
                                      :weight 'normal
                                      :underline nil
                                      :extend nil
                                      :height 1.2
                                      )
                  (set-face-attribute 'org-block-end-line nil
                                      :foreground brushup-fg
                                      :inherit nil
                                      :height 1.2
                                      )
                  )
               )

  :evil
  (evil-set-initial-state 'org-mode 'normal)


  :hydra
  (defhydra+ hydra-org ()
    ("g" (lambda () (interactive)
           (org-refile '(1))) "goto" :column "Navigating")
    ("j" org-next-visible-heading "Next heading")
    ("k" org-previous-visible-heading "Prev heading")
    ("U" outline-up-heading "Up")

    ("J" org-move-subtree-down :column "Edit items")
    ("K" org-move-subtree-up "Move subtree up")
    ("a" (lambda () (interactive)
           (org-insert-heading-respect-content)
           (evil-append 1)) "Append heading" :exit t)
    ("T" (lambda () (interactive)
           (org-insert-heading-respect-content)
           (evil-append 1)) "Append TODO" :exit t)
    ("8" org-toggle-heading "Make heading")

    ("O" org-capture "General capture" :exit t)
    ("z" org-add-note "Add note" :exit t)

    ("S" org-schedule "Schedule" :exit t :column "Plan")
    ("D" org-deadline "Deadline" :exit t)
    ("t" (lambda () (interactive)
           (let ((current-prefix-arg '(4)))
             (call-interactively 'z-org-todo)
             )
           ) "Transition" :exit t)

    ;; tree structure
    ("h" org-metaleft "Promote header" :column "Edit structure")
    ("H" org-shiftmetaleft "Promote subtree")          
    ("l" org-metaright "Demote header")                  ;gives an error for some reason
    ("L" org-shiftmetaright "Demote subtree") 
    ("-" org-cycle-list-bullet "Cycle list bullet")
    ("r" org-refile "Refile" :exit t)
    ("A" org-archive-subtree "Archive")
    ("s" org-sort "Sort subtree")
    ("q" org-columns-quit "Columns quit")
    
    ("TAB" org-cycle "Cycle subtree" :column "Visibility")
    ("S-TAB" org-global-cycle "Cycle file")
    ("i" org-tree-to-indirect-buffer "Indirect buffer")
    ("G" org-sparse-tree "Sparse tree") ; G for graph


    ;; misc
    ("m" org-mark-element "Mark element" :column "Misc")
    ("M" org-mark-subtree "Mark subtree")
    ("C-t" (lambda () (interactive)
             (setq current-prefix-arg '(4))
             (call-interactively 'org-babel-tangle)) "Tangle block" :exit t)
    ("C-S-t" org-babel-tangle "Tangle file" :exit t)

    )

  :general
  (
   :states '(normal visual)
   :keymaps '(org-mode-map)
   "C-d" 'delete-window
   "<S-return>" 'org-edit-special
   )
  (
   :states '(normal insert)
   :keymaps '(org-mode-map org-agenda-mode-map)
   "C-c C-S-o" 'z-org-open-at-point
   "C-c C-o" 'org-open-at-point
   )


  :hook (
         (org-mode . (lambda () (progn
                                  (auto-fill-mode -1)
                                  (visual-line-mode t) 
                                  (progn
                                   (setq visual-fill-column-width 80)
                                   ;; interesting, but not necessary
                                   ;;(setq visual-fill-column-center-text t)
                                   (setq visual-fill-column-width 80)
                                   )
                                  )))
         (org-mode . (lambda () (setq-local fill-column 60)))
         (org-mode . (lambda () (text-scale-set -2)))
         )
  )

(provide 'bootstrap-org)











