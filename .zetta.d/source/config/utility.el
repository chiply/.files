






;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Lookup













(defun z-howdoi ()
  (interactive)
  (let ((query (completing-read "query: " '())))
    (async-shell-command
     ;; command
     (format "howdoi %s" query)
     ;; buffer name
     (format "*howdoi-%s*" query)
     )
    )
  )

;;(z-side "^\\*howdoi-*" 'right 1)







(defhydra+ hydra-lookup ()
  ;; reddit
  ;; twitter
  ("d" define-word-at-point "Dictionary-at-point" :exit t :column "Words")
  ("D" define-word "Dictionary" :exit t)
  ("s" mw-thesaurus-lookup-at-point "Thesaurus" :exit t)
  ("S" mw-thesaurus-lookup "Thesaurus" :exit t)
  ("w" helm-wikipedia-suggest "Wikipedia" :exit t :column "Knowledge")
  ("p" pubmed-search "PubMed" :exit t)
  ("b" ivy-bibtex "(ivy) BibTeX" :exit t)
  ("r" org-roam-ref-find "BibTeX" :exit t)
  ("h" z-howdoi "howdoi" :exit t :column "Code")
  ;; todo add sx and stack overflow
  ;; need to authenticate
  ;; eww search (analgous to a google search)
  ("e" eww "eww" :exit t :column "Web")
  ;; eww bookmarks
  ;; specific eww urls

  ;; pocket
  ("p" pocket-reader "pocket" :exit t)

  )

(general-define-key
 :keymaps 'launch-map
 "l" 'hydra-lookup/body)


;;(general-define-key
;;:keymaps 'evil-insert-state-map
;;(general-chord ",l") 'hydra-lookup/body
;;
;;)
;;
;;(general-define-key
;;:states '(normal visual)
;;:keymaps 'override
;;:prefix ","
;;"l" 'hydra-lookup/body
;;)





(defun z-wget ()
  (interactive)
  (let ((dir "~/Downloads/")
        (url (eww-current-url)))
    ;; download the asset (pdf)
    (async-shell-command
     (concat "cd " dir " && " "wget " url))
    ;; add bibtex entry
    (org-ref-url-html-to-bibtex "~/.files/.lit/bibliography.bib" url)

    )
  )



;; note!  embark act on links browses to them...


;; presumably get these from some interactive function


;; works reasonably well
(defun z-download-pdf ()
  (interactive)
  (let* ((url (eww-current-url))
         (title (read-from-minibuffer "Title: "))
         (key (downcase (replace-regexp-in-string " " "-" title)))
         )
    (async-shell-command (concat "cd ~/Downloads/ && wget " url))

    (progn
      (find-file "~/.files/.lit/bibliography.bib")
      (evil-goto-line)
      (insert
       "\n"
       (format "@online{%s,\n" key)
       (format "  title = {%s},\n" title)
       (format "  url = {%s},\n" url)
       "}\n\n"
       )
      (save-buffer)
      (backward-word)
      (kill-new url)
      (org-ref-open-bibtex-notes)
      )
    )
  ;; download pdf
  )




