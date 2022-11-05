;; should be pushing text to a say file... can be a single location on the filesystem
(defun z-get-selected-text (start end)
    (if (use-region-p)
        (let ((regionp (buffer-substring start end)))
            (message regionp))))

(defun z-say (start end)
  (interactive "r")
  (async-shell-command
   (concat
    "say "
    "-i -r 200 -v Fiona "
    ;; todo: text processing
    (format
     " \"%s\" "
     (string-replace "\n" " " (z-get-selected-text start end)))
    )
   )
  )


