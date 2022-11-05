(use-package helm-wikipedia
  :general
  (
   :keymaps '(helm-wikipedia-map)
   "<return>" 'helm-wikipedia-show-summary-action
   )
  )
