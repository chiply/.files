(use-package flycheck-aspell
  :config
  ;;(setq ispell-dictionary "your_default_dictionary")
  (setq ispell-program-name "aspell")
  (setq ispell-silently-savep t)

  (add-to-list 'flycheck-checkers 'markdown-aspell-dynamic)

  (flycheck-aspell-define-checker "org"
    "Org" ("--add-filter" "url")
    (org-mode))

  (add-to-list 'flycheck-checkers 'org-aspell-dynamic)
  )


(use-package flycheck
  :config
  (setq flycheck-checker-error-threshold 5000)
  (flycheck-define-checker proselint
    "A linter for prose."
    :command ("proselint" source-inplace)
    :error-patterns
    ((warning line-start (file-name) ":" line ":" column ": "
              (id (one-or-more (not (any " "))))
              (message) line-end))
    :modes (text-mode markdown-mode gfm-mode org-mode))

  ;; NOTE: 10 seems to be the minimum width before the filter symbol
  ;; causes issues with overlap
  (setq flycheck-error-list-format
        [("File" 20)
         ("Line" 10 flycheck-error-list-entry-<)
         ("Col" 10 nil)
         ("Level" 15 flycheck-error-list-entry-level-<)
         ("ID" 26 t)
         (#("Message (Checker)" 0 7
            (face flycheck-error-list-error-message)
            9 16
            (face flycheck-error-list-checker-name))
          0 t)])

  ;; this is necessary!  eg run proselint after org-aspell-dynamic
  ;; from here https://github.com/flycheck/flycheck/issues/186
  (flycheck-add-next-checker 'org-aspell-dynamic 'proselint)
  
  ;;:brushup
  ;;(add-to-list 'brushup-styles
               ;;'(progn
                  ;;(set-face-attribute 'flycheck-fringe-error nil
                                      ;;:foreground brushup-fg
                                      ;;:background (modus-themes-get-color-value 'bg-red-nuanced))
                  ;;(set-face-attribute 'flycheck-fringe-warning nil
                                      ;;:foreground brushup-fg
                                      ;;:background (modus-themes-get-color-value 'bg-blue-nuanced))
                  ;;(set-face-attribute 'flycheck-fringe-info nil
                                      ;;:foreground brushup-fg
                                      ;;:background brushup-bg-1_0)
                  ;;)
               ;;)

  :display
  (z-side "^\\*Flycheck*" 'top)

  :hook (
         (flycheck-error-list . (lambda () (text-scale-set -2)))
         (org-mode . flycheck-mode)
         )
  )
