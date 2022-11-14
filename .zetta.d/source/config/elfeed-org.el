(use-package elfeed-org
  :after elfeed org
  :config
  (setq rmh-elfeed-org-files (list
                              (expand-file-name "~/.files/.zetta.d/elfeed.org")
                              ))
  (elfeed-org)
  )
