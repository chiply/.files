(use-package image-mode
  :straight nil
  :demand t
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
