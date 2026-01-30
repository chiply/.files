(use-package org-capture
  :straight nil

  :init
  (setq org-capture-templates
        '(
          ;; LEFT OFF - can keep this around, but make another for public-- captal should be public
          ;;(
          ;;"H" "Linked header"
          ;;entry
          ;;(file "~/.files/org-roam/agenda.org")
           ;;;; note using custom function from above
           ;;;; can refine thiis... But for now it's a dumb link to the originial file.  org-roam processes this since
           ;;;; the target is an org-roam directory
          ;;"* INBOX %(if (file-exists-p (zett-org-get-title (org-capture-get :original-file))) \"\" \"[[file:%(abbreviate-file-name (org-capture-get :original-file))][%(zett-org-get-title (org-capture-get :original-file))]] \") :: %?\n"
          ;;:prepend t
          ;;) 
          ;; TODO add linked versions
          (
           "o" "simple"
           entry
           (file "~/logseq/graphs/main/pages/capture.org")
           ;; note using custom function from above
           "* %?\n%a"
           :prepend t
           )
          )
        )

  ;;:hook (org-capture-after-finalize . z-refresh-agenda)
  )
