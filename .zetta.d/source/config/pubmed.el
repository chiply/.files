(use-package pubmed
  :config
  (setq pubmed-bibtex-default-file "~/.files/.lit/bibliography.bib")
  (setq pubmed-bibtex-keypattern "[auth][year][shorttitle]")
  (add-hook 'pubmed-mode-hook #'display-line-numbers-mode)
  (add-hook 'pubmed-show-mode-hook #'display-line-numbers-mode)

  :general
  (
   :keymaps 'pubmed-mode-map
   "C-<return>" 'pubmed-bibtex-write
   )
  )
