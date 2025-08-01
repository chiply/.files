(use-package pdf-tools
  :config
  (pdf-tools-install)

  :general
  (
   :keymaps '(pdf-view-mode-map)
   "C-S-j" 'pdf-view-next-page
   "C-S-k" 'pdf-view-previous-page))
