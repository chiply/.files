(use-package telephone-line
  :config

  (telephone-line-defsegment zt-ace-1 ()
    (propertize
     (window-parameter (selected-window) 'ace-window-path)
     'face 'ef-themes-heading-0))

  (telephone-line-defsegment zt-icon-file-or-buffer ()
    (let ((fname (buffer-file-name)))
      (if fname
          (all-the-icons-icon-for-file fname)
        (all-the-icons-icon-for-mode major-mode))))

  (telephone-line-defsegment zt-icon-lsp ()
    (when (and (boundp 'lsp-mode) lsp-mode)
      (all-the-icons-icon-for-mode 'lsp-mode)))

  (telephone-line-defsegment zt-icon-copilot ()
    (when (and (boundp 'copilot-mode) copilot-mode)
      (all-the-icons-icon-for-mode 'copilot-mode))
    )


  (telephone-line-defsegment zt-icon-side-window ()
    (when (z-side-window-p (selected-window)) " {S} "))


  (telephone-line-defsegment zt-path ()
    (let ((path (abbreviate-file-name default-directory)))
      (if (> (length path) 30) (z-minify-path default-directory) path)))

  (telephone-line-defsegment zt-vc-segment-repo-icon ()
    (let ((result (shell-command-to-string
                   "git rev-parse --is-inside-work-tree")))
      (when (and result (string= result "true\n"))
        ;; HACKY: note that some icons still come through
        ;; with the blank background and get resized whenever
        ;; i change the fontsize in the buffer.
        ;; icon-for-mode and icon-for-file seems to work well
        ;; for this, but only when the relevant entry in
        ;; `all-the-icons-mode-icon-alist` or `...` has a
        ;; face set (and this face does not inherit the
        ;; default font.).  Desired setup up is to be able to
        ;; directly reference any icon and insert here, but
        ;; I'm having to use the *-for-* functions in order
        ;; to get an icon that is fixed height in the
        ;; modeline
        (all-the-icons-icon-for-mode 'magit-status-mode)
        ))
    )

  (telephone-line-defsegment zt-vc-segment-repo ()
    (let ((result (shell-command-to-string
                   "git rev-parse --is-inside-work-tree")))
      (when (and result (string= result "true\n"))
        (nth 0 (z-get-repo-name)))))

  (telephone-line-defsegment zt-vc-segment-branch ()
    (let ((result (shell-command-to-string
                   "git rev-parse --is-inside-work-tree")))
      (when (and result (string= result "true\n"))
        (vc-git--symbolic-ref (or (buffer-file-name) default-directory)))))


  (telephone-line-defsegment zt-flycheck-segment ()
    (let ((text (flycheck-indicator--mode-line)))
      (if (string= " not-checked" text) "" text)))

  (telephone-line-defsegment zt-zmc-segment ()
    (concat (or (if (boundp 'latest-transient) latest-transient) (if (boundp 'local-transient) local-transient)) " "))

  (telephone-line-defsegment zt-postition-segment ()
    "%c|%l(%p)"
    )

  (telephone-line-defsegment zt-indicators-segment ()
    ;; note making letters now as there are still issues with
    ;; faces for SVG branch of all-the-icons
    ;; Not sure if actually the ones that change size are the
    ;; intende behavior.  Either way, I tihk it has to do with
    ;; scale attribute of the SVG and there must be a way to
    ;; change this
    ;; Actaulyl the scale attribute is not the culprit here as the
    ;; icons that do have fixed fonts actually have scale 1 as
    ;; well.  Didn't see a difference in the attributes between
    ;; the working and not working icons... will just table this
    ;; for now as I can hack around this by using one of the
    ;; icon-for commands
    ;; TODO separate this out
    (concat
     (let ((icon (z-line-tramp-icon))) (when icon "T"))
     (let ((icon (z-line-docker-icon))) (when icon "D"))
     (let ((icon (z-line-narrowed-icon))) (when icon "N"))
     (let ((icon (z-line-hydra-indicator-icon))) (when icon "H"))))

  (telephone-line-defsegment zt-anzu-segment ()
    (anzu--update-mode-line)
    )

  (telephone-line-defsegment zt-iedit-segment ()
    (let ((icon (z-line-iedit-icon)))
      (when icon 
        ;; the car of iedit-mode-line unioned with the cdr of iedit-mode-line
        (cons (replace-regexp-in-string " " "" 
                                        (car iedit-mode-line) )
              (cdr iedit-mode-line)
              ))))

  (setq telephone-line-primary-left-separator 'telephone-line-halfcos-left
        telephone-line-primary-right-separator 'telephone-line-halfcos-right
        telephone-line-secondary-left-separator 'telephone-line-nil
        telephone-line-secondary-right-separator 'telephone-line-nil)

  (setq telephone-line-faces
        '((evil . telephone-line-modal-face)
          (modal . telephone-line-modal-face)
          (ryo . telephone-line-ryo-modal-face)
          (accent . (telephone-line-accent-active . telephone-line-accent-inactive))
          (nil . (mode-line . mode-line-inactive))
          (foo . (modus-themes-subtle-blue . modus-themes-nuanced-blue))
          (bar . (modus-themes-subtle-magenta . modus-themes-nuanced-magenta))
          (barr . (modus-themes-intense-magenta . modus-themes-nuanced-magenta))
          (iedit . (iedit-occurrence . iedit-occurrence))
          ))

  (setq telephone-line-subseparator-faces '())

  (setq telephone-line-lhs
        '((evil . (telephone-line-evil-tag-segment telephone-line-meow-tag-segment))
          (accent . (zt-ace-1))
          (foo . (zt-icon-file-or-buffer zt-icon-copilot zt-icon-lsp))
          (bar . (zt-icon-side-window zt-path)) ;;foo
          (barr . (zt-vc-segment-repo-icon
                   ;; TODO: move this info to the title bar or tab-bar?  lots of space there...
                   ;;zt-vc-segment-repo zt-vc-segment-branch
                   ))
          (foo . (zt-indicators-segment))
          (bar . (zt-iedit-segment))
          (accent . (zt-anzu-segment))
          (nil . (zt-flycheck-segment))
          (nil . (zt-postition-segment))
          ))


  (setq telephone-line-rhs nil)
  (setq telephone-line-evil-use-short-tag t)
  (setq telephone-line-height 14) ;; lower and it doesn't render correctly
  (setq telephone-line-separator-extra-padding 0)

  (telephone-line-mode 1)

  )




