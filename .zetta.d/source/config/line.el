;; -*- lexical-binding: t; -*-


(setq default-line-align-left-devel
      '(
        (:eval (when (or
                      (eq major-mode 'docker-image-mode)
                      (eq major-mode 'docker-container-mode)
                      (eq major-mode 'docker-volume-mode)
                      (eq major-mode 'embark-collect-mode)
                      )
                 (propertize
                  (window-parameter (selected-window) 'ace-window-path)
                  'face 'focus-focused)))
        " "
        (:eval 
         (lsp-headerline--build-string)
         (z-yaml-json-info)
         )
        " "
        (:eval
         (when (string= major-mode "org-mode") (concat " > " (org-display-outline-path) "/" (org-get-heading)))
         )
        " "
        (:eval (cond
                ((or
                  ;; anything using yaml
                  (equal major-mode 'docker-compose-mode)
                  (equal major-mode 'yaml-mode))
                 (concat "{" (jpt-yaml-path-to-point) "}"))
                ((or
                  (equal major-mode 'jsonian-mode))
                 (concat "{" (jsons-get-path-python) "}"))
                ))
        )
      )

(setq default-line-align-left
      '(
        " "
        (:eval (propertize
                (window-parameter (selected-window) 'ace-window-path)
                'face 'focus-focused))
        (:eval (when (z-side-window-p (selected-window))
                 (propertize " {S} " 'face 'focus-unfocused)))
        " "
        (:eval
         (let ((path (abbreviate-file-name default-directory)))
           (if (> (length path) 30)
               (z-minify-path default-directory)
             path
             )
           ))
        (:eval (when (string= major-mode "python-mode")
                 (propertize
                  (concat " [" pyvenv-virtual-env-name "]")
                  'face 'focus-unfocused
                  )))
        (:eval (when (or
                      (z-line-tramp-icon)
                      (z-line-docker-icon)
                      (z-line-narrowed-icon)
                      (z-line-iedit-icon)
                      (z-line-hydra-indicator-icon)
                      )
                 " "))
        (:eval (let ((icon (z-line-tramp-icon)))
                 (when icon (propertize "T" 'face 'focus-unfocused))))
        ;;(:eval (let ((icon (z-line-modified-icon)))
        ;;(when icon (propertize "M" 'face 'focus-unfocused))))
        (:eval (let ((icon (z-line-docker-icon)))
                 (when icon (propertize "D" 'face 'focus-unfocused))))
        (:eval (let ((icon (z-line-narrowed-icon)))
                 (when icon (propertize "N" 'face 'focus-unfocused))))
        (:eval (let ((icon (z-line-iedit-icon)))
                 (when icon (propertize "E" 'face 'focus-unfocused))))
        (:eval (let ((icon (z-line-hydra-indicator-icon)))
                 (when icon (propertize "H" 'face 'focus-unfocused))))
        (:eval (anzu--update-mode-line))
        (vc-mode vc-mode)
        flycheck-mode-line
        ;;(:eval (parrot-create))
        ;;(:eval (z-get-tab-line-string))
        ;;" "
        " "
        (:eval (propertize "%c(%p)" 'face 'focus-unfocused))
        )
      )


(setq default-line-align-middle '(""))
(setq default-line-align-right '(""))
(setq-default mode-line-format (z-get-line-format default-line-align-left "" ""))
(setq anzu-cons-mode-line-p nil)
(setq-default header-line-format (z-get-line-format default-line-align-left-devel "" ""))



;; leaves all but last dir
(defun z-minify-path (path)
  (let* ((path (abbreviate-file-name path))
         (path-split (split-string path "/"))
         (leaf-dir-name (car (last path-split 2)))
         (path-split (butlast path-split 2))
         )
    (concat
     (mapconcat
      (lambda (s)
        (if (> (length s) 1)
            (substring s 0 2)
          (substring s 0 1))
        )
      path-split
      "/"
      )
     "/"
     leaf-dir-name
     )
    )
  )

;; for apps that strangely don't take the defaults
(add-hook 'treemacs-mode-hook
          '(lambda ()
             (setq mode-line-format
                   (list
                    '(:eval
                      (let ((path (abbreviate-file-name default-directory)))
                        (if (> (length path) 30)
                            (z-minify-path default-directory)
                          path
                          )
                        ))
                    ))
             (setq header-line-format (list
                                       '(:eval (z-get-repo-name))
                                       ":"
                                       '(:eval (z-get-branch-name))
                                       )
                   )
             )
          )



(add-hook 'eaf-mode-hook
          '(lambda ()
             (setq mode-line-format
                   (z-get-line-format default-line-align-left "" "")
                   )
             )
          )

