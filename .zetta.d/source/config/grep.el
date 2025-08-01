(use-package grep
  :ensure nil
  :demand t
  :after embark
  :config
  (add-to-list 'auto-mode-alist '("\\.grep\\'" . grep-mode))

  ;; TODO doesn't work
  (general-unbind 'grep-mode-map "g r")
  :general
  (
   :keymaps 'grep-mode-map
   "g r" 'embark-rerun-collect-or-export
   )
  )

