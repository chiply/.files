(use-package org-remark
  :config
  (require 'org-remark-global-tracking)
  (org-remark-global-tracking-mode +1)

  (use-package org-remark-info :ensure nil :after info :config (org-remark-info-mode +1))
  (use-package org-remark-wombag  :ensure nil :after eww  :config (org-remark-wombag-mode +1))
  (use-package org-remark-nov  :ensure nil :after nov  :config (org-remark-nov-mode +1))

  :bind (;; :bind keyword also implicitly defers org-remark itself.
         ;; Keybindings before :map is set for global-map. Adjust the keybinds
         ;; as you see fit.
         ("C-c n m" . org-remark-mark)
         ("C-c n l" . org-remark-mark-line)
         :map org-remark-mode-map
         ("C-c n o" . org-remark-open)
         ("C-c n ]" . org-remark-view-next)
         ("C-c n [" . org-remark-view-prev)
         ("C-c n r" . org-remark-remove)
         ("C-c n d" . org-remark-delete)))

(define-minor-mode org-remark-wombag-mode
  "Enable Org-remark to work with EWW."
  :global t
  :group 'org-remark-wombag
  (if org-remark-wombag-mode
      ;; Enable
      (progn
        (add-hook 'wombag-post-html-render-hook #'org-remark-auto-on)
        (add-hook 'org-remark-source-find-file-name-functions
                  #'org-remark-wombag-find-file-name)
        (add-hook 'org-remark-highlight-link-to-source-functions
                  #'org-remark-wombag-highlight-link-to-source))
      ;; Disable
      (remove-hook 'wombag-post-html-render-hook #'org-remark-auto-on)
      (remove-hook 'org-remark-source-find-file-name-functions
                   #'org-remark-wombag-find-file-name)
      (remove-hook 'org-remark-highlight-link-to-source-functions
                   #'org-remark-wombag-highlight-link-to-source)))

(defun org-remark-wombag-find-file-name ()
  "Return URL without the protocol as the file name for the website.
It assumes the buffer is the source website to be annotated.
This function is meant to be set to hook
`org-remark-source-find-file-name-functions'."
  (when (eq major-mode 'wombag-show-mode)
    (let ((url-parsed (url-generic-parse-url (alist-get 'url wombag-show-entry))))
      (concat (url-host url-parsed) (url-filename url-parsed)))))

(defun org-remark-wombag-highlight-link-to-source (filename _point)
  "Return URL pointinting to the source website (FILENAME).
It assumes https:
This function is meant to be set to hook
`org-remark-highlight-link-to-source-functions'."
  (when (eq major-mode 'wombag-show-mode)
    ;;; FIXME we shhould not assume https?
    (concat "[[https://" filename "]]")))


(org-remark-wombag-mode)
