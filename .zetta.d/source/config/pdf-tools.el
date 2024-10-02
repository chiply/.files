(use-package pdf-tools
  :config
  (pdf-tools-install)

  ;;:display
  
  ;;(z-side "pdf-occur-buffer-mode" 'left 1)
  ;;(z-side "^\\*Outline*" 'left 3)

  :general
  (
   :keymaps '(pdf-view-mode-map)
   "C-S-j" 'pdf-view-next-page
   "C-S-k" 'pdf-view-previous-page
   )

  )
