(use-package consult-gh
  ;;:straight (consult-gh :type git :host github :repo "armindarvish/consult-gh" :branch "main" :files ("*.el"))
  :ensure (:wait t)
  :demand t
  :after consult

  :config
  ;;add your main GitHub account (replace "armindarvish" with your user or org)
  (add-to-list 'consult-gh-default-orgs-list "")

  ;;use "gh org list" to get a list of all your organizations and adds them to default list
  (setq consult-gh-default-orgs-list (append consult-gh-default-orgs-list (remove "" (split-string (or (consult-gh--command-to-string "org" "list") "") "\n"))))

  ;; set the default folder for cloning repositories, By default Consult-GH will confirm this before cloning
  (setq consult-gh-default-clone-directory "~/source_code/")
  (require 'consult-gh-embark)
)

