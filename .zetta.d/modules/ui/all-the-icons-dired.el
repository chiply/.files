(use-package all-the-icons-dired
  :init
  (defun z-enable-dired-icons-maybe ()
    (unless (file-remote-p default-directory)
      (all-the-icons-dired-mode)
      )
    )

  :brushup
  (add-to-list 'brushup-styles
               '(set-face-attribute 'all-the-icons-dired-dir-face nil
                                    :height 1.0
                                    :foreground brushup-fg-3))

  :hook ((dired-mode . (lambda () (z-enable-dired-icons-maybe)))
         (use-package--all-the-icons-dired--post-config . (lambda () (z-brushup))))
  )
