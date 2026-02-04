(use-package image-mode
  :ensure nil
  :commands image-mode
  :config
  (defun z-image-mode-eaf-open ()
    (interactive)
    (eaf-open (buffer-file-name (current-buffer)))
    )

  :general
  (
   :keymaps 'image-mode-map
   "<C-return>" 'z-image-mode-eaf-open
   )
  )
