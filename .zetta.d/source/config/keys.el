(general-define-key
 :keymaps 'override
 "C-s" 'save-buffer)

(defun z-projectile-find-file ()
  (interactive)
  (if (projectile-project-p)
      (projectile-find-file)
    (call-interactively 'find-file)
    )
  )

(general-define-key
 :keymaps 'evil-insert-state-map
 (general-chord ",o") 'hydra-org/body
 (general-chord ",b") 'consult-buffer
 (general-chord ",B") 'consult-buffer
 (general-chord ",x") 'execute-extended-command
 (general-chord ",f") 'z-projectile-find-file
 (general-chord ",F") 'find-file
 (general-chord ",k") 'kill-this-buffer
 (general-chord ",a")
 '(lambda () (interactive)
    (z-org-agenda "1" org-super-agenda-groups-main)
    (org-agenda-redo) 
    )
 )

(general-define-key
 :states '(normal visual)
 :keymaps 'override
 :prefix ","
 ;; hydra 
 "o" 'hydra-org/body
 "b" 'consult-buffer
 "B" 'consult-buffer
 "x" 'execute-extended-command
 "f" 'z-projectile-find-file
 "F" 'find-file
 "k" 'kill-this-buffer
 "a" '(lambda () (interactive)
        (z-org-agenda "1" org-super-agenda-groups-main)
        (org-agenda-redo) 
        )
 )

(general-define-key
 :keymaps '(evil-insert-state-map
            evil-normal-state-map
            evil-visual-state-map
            evil-motion-state-map)
 "C-e" nil
 )

(general-define-key
 :states '(normal visual)
 :keymaps '(pubmed-mode-map)
 "<return>" 'pubmed-show-current-entry
 "<tab>" 'pubmed-bibtex-show
 "f" 'pubmed-get-fulltext
 "s" 'pubmed-search
 )

(general-unbind
  :states '(normal visual)
  :keymaps '(web-mode-map)
  "C-e")


