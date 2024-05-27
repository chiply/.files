(use-package forge
  :after magit
  ;; notes: need to set up github username locally for each repo
  ;; with this command
  ;; git config --global github.user USERNAME
  ;; git config --local github.user USERNAME
  :init
  (setq auth-sources '("~/.authinfo"))
  ;;(z-side "\\forge-topic-mode" 'right 2)


  :general
  (
   :keymaps 'magit-status-mode-map
   "P" 'forge-pull
   )
  )
