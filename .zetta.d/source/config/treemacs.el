(use-package treemacs
  ;;:requires (treemacs-all-the-icons)
  :demand t 

  :init
  (setq treemacs-persist-file (expand-file-name ".data/treemacs/.cache/treemacs-persist" user-emacs-directory))

  
  :config
  ;;(use-package treemacs-nerd-icons
    ;;:functions treemacs-load-theme
    ;;:config
    ;;(treemacs-load-theme "nerd-icons"))

  (use-package treemacs-all-the-icons
    :config
    (treemacs-load-theme "all-the-icons"))
  
  (setq aw-ignored-buffers '("*Calc Trail*" " *LV*"))


  (setq-default
   ;;treemacs--project-follow-delay 0.25
   treemacs-file-follow-delay 0.25
   treemacs-file-event-delay 1000
   treemacs-tag-follow-delay 0.25
   ;; makes it take up more screen realestate
   ;; and based on treemacs defauults of 1 buffer per frame
   ;; this bahaves a lot like frame-level contruct
   treemacs-display-in-side-window t
   treemacs-width 35
   treemacs-width-is-initially-locked nil
   )
  ;; very odd.. order matters here..., esp when it comes to files that lack tags
  ;; in the other order, there is an issue with the followign of files without tags
  (treemacs-follow-mode nil)
  (treemacs-project-follow-mode nil)
  (treemacs-tag-follow-mode nil)

  (treemacs-filewatch-mode t)



  (defun z-refresh-treemacs ()
    (interactive)
    (let ((treemacs-buf (nth 0 (z-soda-mode-displayed-p "treemacs-mode")))
          (win (selected-window))
          )
      (when treemacs-buf
        (progn
          (kill-buffer treemacs-buf)
          (treemacs)
          (select-window win)
          )
        )
      )
    )

  :brushup
  (add-to-list 'brushup-styles
               '(progn
                  ;;(set-face-attribute 'treemacs-all-the-icons-file-face nil
                  ;;:foreground brushup-fg-1)
                  ;;(set-face-attribute 'treemacs-git-ignored-face nil
                  ;;:foreground brushup-bg-5)
                  ;;(set-face-attribute 'treemacs-git-untracked-face nil
                  ;;:underline t
                  ;;:foreground brushup-bg-5)
                  ;;(set-face-attribute 'treemacs-git-modified-face nil
                  ;;:underline nil
                  ;;:foreground brushup-fg :box nil :weight 'bold)
                  (set-face-attribute 'treemacs-root-face nil
                                      :height 1.2
                                      :foreground brushup-fg-2
                                      )
                  (setq treemacs-width (floor (* 0.10 (frame-total-cols))))

                  ))

  ;; toggle single project view

  ;; toggle treemacs with ,t;;; so it's  ,d for dired, ,b for buffer ,t for treemacs

  :hydra
  (defhydra+ hydra-run () 
    ("t" (lambda () (interactive)
           (let* ((bufnm (current-buffer))
                  (win (get-buffer-window bufnm))
                  (treemacs-buf (nth 0 (z-soda-mode-displayed-p "treemacs-mode")))
                  )
             (if treemacs-buf
                 (select-window (get-buffer-window treemacs-buf))
               (progn
                 (treemacs)
                 (select-window win)
                 )
               ) 
             )))
    ("T" treemacs) 
    ("C-t" z-refresh-treemacs)
    ("M-t" (lambda () (interactive)
             (if treemacs-tag-follow-mode
                 (progn
                   (treemacs-tag-follow-mode -1)
                   ;; need this as treemacs tag follow mode -1 affects follow mode
                   ;; SO STRANGE.. but this seems to sovle the issie of not having proper tracking
                   ;; to to lack of tags in a file.  I can get file based following in the files where
                   ;; I run this function.  Not expectetd, but works!
                   (treemacs-follow-mode 1)
                   )
               (treemacs-tag-follow-mode 1))
             ))
    )



  :general
  (
   :keymaps '(treemacs-mode-map)
   "o" 'treemacs-visit-node-ace
   "h" 'treemacs-visit-node-ace-horizontal-split
   "v" 'treemacs-visit-node-ace-vertical-split
   "d" 'treemacs-delete-file
   )

  :hook (
         (use-package--treemacs--post-config . z-brushup)
         (treemacs-mode . (lambda ()
                            (text-scale-set -2)
                            (toggle-truncate-lines -1)
                            ))
         ;; note is somewhat close to the behavior of having frame specific treemacs buffers, or at least satisfies the same usecase
         ;;((python-ts-mode emacs-lisp-mode sql-mode) . z-setup-treemacs-for-buffer)
         )
  )

(use-package treemacs-magit)

