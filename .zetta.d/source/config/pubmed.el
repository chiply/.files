(use-package pubmed
  :ensure (:host gitlab :repo "fvdbeek/emacs-pubmed")

  :commands (pubmed-search pubmed-advanced-search)

  :config
  (setq pubmed-bibtex-default-file (expand-file-name "~/.files/.lit/bibliography.bib"))
  (setq pubmed-bibtex-keypattern "[auth][year][shorttitle]")
  (add-hook 'pubmed-mode-hook #'display-line-numbers-mode)
  (add-hook 'pubmed-show-mode-hook #'display-line-numbers-mode)

  ;; to fix bibtex not working
  (load-file (expand-file-name "source/straight/repos/emacs-pubmed/pubmed-bibtex.el" user-emacs-directory) )


  :general
  (
   :keymaps 'pubmed-mode-map
   "C-<return>" 'pubmed-bibtex-write
   )
  (
   :keymaps 'menu-lookup-map
   "p" 'pubmed-search
   )
  )
