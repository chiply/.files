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

  (setq org-roam-capture-templates
        '(
          ("d" "default" plain "%?" :target
           (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n")
           :unnarrowed t)
          ("D" "default" plain "%?\n%a\n%F" :target
           (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n")
           :unnarrowed t)
          )
        )

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

  :general 
  (
   :keymaps 'override
   "s-o" 'z-org-roam-node-find
   "s-O" 'z-org-roam-capture
   "s-i" 'org-roam-node-insert
   )
  )
