;; -*- lexical-binding: t; -*-

;; REFACTOR!
;; separate modeline functions
;; this will make it read much much clearner
;; z-line-...


(setq default-line-align-left-devel
      '(
        (:eval (when (or
                      (eq major-mode 'docker-image-mode)
                      (eq major-mode 'docker-container-mode)
                      (eq major-mode 'docker-volume-mode)
                      (eq major-mode 'embark-collect-mode))
                 (propertize
                  (window-parameter (selected-window) 'ace-window-path)
                  'face 'focus-focused)))
        " "
        (:eval (if (string= (symbol-name major-mode) "magit-status-mode") (parrot-create)))
        (:eval (spinner-print spinner-current))
        (:eval (when (eq major-mode 'magit-status-mode) (nyan-create)))
        (:eval
         (when (string= major-mode "org-mode")
           (concat " > " (org-display-outline-path) "/" (org-get-heading))))
        " "
        (:eval (cond
                ((or (equal major-mode 'docker-compose-mode)
                     (equal major-mode 'yaml-mode))
                 (concat "{" (jpt-yaml-path-to-point) "}"))
                ((or (equal major-mode 'jsonian-mode))
                 (concat "{" (jsons-get-path-python) "}"))))))

(setq default-line-align-left
      '(
        ;;(:eval (nerd-icons-icon-for-file (buffer-file-name)))
        ;;" "
        (:eval (propertize
                (window-parameter (selected-window) 'ace-window-path)
                'face 'focus-focused))
        ;;" "
        ;;(:eval (meow-indicator))
        " "
        (:eval (when (z-side-window-p (selected-window)) " {S} "))
        " "
        (:eval
         (let ((path (abbreviate-file-name default-directory)))
           (if (> (length path) 30) (z-minify-path default-directory) path)))

        (:eval (when (string= major-mode "python-ts-mode")
                 (concat " [" pyvenv-virtual-env-name "]")))
        (:eval (when (or
                      (z-line-tramp-icon)
                      (z-line-docker-icon)
                      (z-line-narrowed-icon)
                      (z-line-iedit-icon)
                      (z-line-hydra-indicator-icon)
                      )
                 " "))
        (:eval (let ((icon (z-line-tramp-icon))) (when icon "T")))
        (:eval (let ((icon (z-line-docker-icon))) (when icon "D")))
        (:eval (let ((icon (z-line-narrowed-icon))) (when icon "N")))
        (:eval (let ((icon (z-line-iedit-icon))) (when icon "E")))
        (:eval (let ((icon (z-line-hydra-indicator-icon))) (when icon "H")))
        (:eval (anzu--update-mode-line))
        ;; if in a git project, the name of the project
        " "
        "{" (:eval (nth 0 (z-get-repo-name))) (vc-mode vc-mode) "}"
        flycheck-mode-line
        " "
        (:eval  "%c(%p)")
        " "
        (:eval (or (if (boundp 'latest-transient) latest-transient) (if (boundp 'local-transient) local-transient)))
        )
      )


(setq default-line-align-middle '(""))
(setq default-line-align-right '(""))


(setq anzu-cons-mode-line-p nil)


(setq-default mode-line-format (z-get-line-format default-line-align-left "" ""))
(setq-default header-line-format (z-get-line-format default-line-align-left-devel "" ""))


;; for apps that strangely don't take the defaults
(add-hook 'treemacs-mode-hook
          '(lambda ()
             (setq mode-line-format
                   (list
                    '(:eval
                      (let ((path (abbreviate-file-name default-directory)))
                        (if (> (length path) 30)
                            (z-minify-path default-directory)
                          path)))))
             (setq header-line-format (list
                                       '(:eval (z-get-repo-name))
                                       ":"
                                       '(:eval (z-get-branch-name))
                                       ))))

