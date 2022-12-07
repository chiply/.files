(use-package yasnippet
  :demand t

  :init

  (setq yas-triggers-in-field t
        yas-indent-line 'fixed
        yas-wrap-around-region 'nil
        yas-snippet-dirs
        `(
          ,(format "%ssource/snippets/snippets/test" user-emacs-directory)
          ,(format "%ssource/snippets/snippets/personal" user-emacs-directory)
          )
        )

  (yas-global-mode 1)

  


  (defun z-snippet-file-displayed-p ()
    (interactive)
    (let* ((buffers-being-displayed (-filter
                                     (lambda (x) (z-soda-buffer-displayed-p x))
                                     (buffer-list)))
           (names-of-buffers-being-displayed (-map
                                              (lambda (x) (buffer-name x))
                                              buffers-being-displayed)))
      (if (member ".snippets.org" names-of-buffers-being-displayed)
          t
        nil
        )
      )
    )

  (defun z-snip-view-snippet-file ()
    (interactive)
    (let ((dir user-emacs-directory))
      (select-window
       (display-buffer
        (find-file-noselect (format "%ssource/snippets/.snippets.org" dir))))
      )
    )

  (defun z-snip-search-snippets ()
    (interactive)
    (let ((mode (symbol-name major-mode))
          (win (selected-window))
          (selectrum-display-style '(vertical))
          (inhibit-quit t)
          )
      (unless (with-local-quit
                (z-snip-view-snippet-file)
                (consult-line (concat mode " "))
                t)
        (progn
          (select-window win)
          (setq quit-flag nil)
          )
        )
      )
    )

  ;; got from
  ;; https://emacs.stackexchange.com/questions/61108/make-tangle-dont-add-a-newline-at-the-end-of-the-file
  (defun z-zap-newline-at-eob ()
    (let ((make-backup-files nil)) 
      (message "running z-zap-newline-at-eob")
      (goto-char (point-max))
      (when (equal (char-before) ?\n)
        (delete-char -1)
        (save-buffer))))

  (defun z-snip-tangle-and-load (&optional file)
    (interactive)
    (add-hook 'org-babel-post-tangle-hook #'z-zap-newline-at-eob)
    (if file
        (org-babel-tangle-file file)
      (org-babel-tangle)
      )
    (yas-reload-all)
    (remove-hook 'org-babel-post-tangle-hook #'z-zap-newline-at-eob)
    )

  (defun z-snip-new-snippet ()
    (interactive)
    (let ((mode (symbol-name major-mode))
          (win (selected-window))
          (selectrum-display-style '(vertical))
          (inhibit-quit t)
          )
      (if (with-local-quit
            (z-snip-view-snippet-file)
            (consult-line (concat mode " ") 1)
            (org-end-of-subtree)
            t)
          (progn
            (insert "\nzsnip")
            (call-interactively 'evil-insert)
            (yas-expand)
            )
        (progn
          (select-window win)
          (setq quit-flag nil)
          )
        )
      ) 
    )

  (z-snip-tangle-and-load (format "%ssource/snippets/.snippets.org" user-emacs-directory))

  :display
  (z-side "snippet-mode" 'right 1) 

  :hydra
  (defhydra+ hydra-yas ()
    ("n" z-snip-new-snippet "New" :exit t)
    ("f" z-snip-search-snippets "Go to Snippets" :exit t)
    )


  :general
  (
   :keymaps 'evil-insert-state-map
   (general-chord ",y") 'hydra-yas/body
   )
  (
   :states '(normal visual)
   :keymaps 'override
   :prefix ","
   "y" 'hydra-yas/body
   )
  (
   :keymaps 'yas-keymap
   "C-;" 'z-completion-at-point
   "<tab>" 'yas-next-field
   "<S-tab>" 'yas-prev-field
   )


  ;;(eval-after-load 'yasnippet
  ;;'(progn
  ;;(define-key yas-keymap (kbd "C-;") 'z-completion-at-point)
  ;;(define-key yas-keymap (kbd "<tab>") 'yas-next-field)
  ;;(define-key yas-keymap (kbd "<S-tab>") 'yas-prev-field)
  ;;)
  ;;)

  :hook (snippet-mode . (lambda () (text-scale-set -2)))
  )


(use-package yasnippet-snippets
  )

(use-package py-snippets
  :after yasnippet
  :config
  (py-snippets-initialize))

;; (use-package sphinx-doc
;;   :config
;;   (setq sphinx-doc-include-types nil)
;;   (add-hook 'python-mode-hook (lambda ()
;;                                 (require 'sphinx-doc)
;;                                 (sphinx-doc-mode t)))
;;   )

;; not the greatest, but it's one of the better solutions that
;; actually supports type hinting
(use-package numpydoc
  :config
  (setq numpydoc-insertion-style nil)
  :bind (:map python-mode-map
              ("C-c C-n" . numpydoc-generate)))


;; excellent for discoverability.  like autocompletion, but at the top
;; level for all snippets
;; a really great demo workflow is to open up a buffer in an
;; unfamiliar proigramming language and ismply search for 'function',
;; which will give you the syntax for a function.
(use-package consult-yasnippet)




