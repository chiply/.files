(defvar zetta-literature-dir "~/.lit/"
  "Directory for bibliography files and PDFs. Set in ~/.zetta.el.")

(use-package biblio
  :config
  (setq biblio-download-directory (expand-file-name "pdf/" zetta-literature-dir))
  )
