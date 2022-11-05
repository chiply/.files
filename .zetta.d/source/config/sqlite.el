(defun z-sql-set-engine (arg)
  (interactive "P")
  (let ((engine (if (or arg
                        (not (boundp 'z-sql-engine)))
                    (ido-completing-read "Please enter a source: " '("oracle" "sqlite"))
                  (message z-sql-engine))))
    (setq-local z-sql-engine engine)))

(defun z-sqlite-set-dbfile (arg)
  (interactive "P")
  (let* ((dbs (-filter
               (lambda (x) (member "db" (split-string x "\\.")))
               (split-string (shell-command-to-string "ls") "\n")))
         (dbfile (if (or arg
                         (not (boundp 'z-sqlite-dbfile)))
                     (ido-completing-read "Please enter a source: " dbs)
                   (message z-sqlite-dbfile))))
    (setq-local z-sqlite-dbfile dbfile)))

(defun z-set-async-output-buffer-for-buffer (&optional arg)
  (let* ((user-tag (if (or arg (not (boundp 'z-output-buffer-for-buffer)))
                       (completing-read "Name the output buffer: " (-map (lambda (x) (buffer-name x))
                                                                         (z-soda-list-mode-buffers "shell-mode")))
                     z-output-buffer-for-buffer))

         (buffer-name (if (string-match "*sql--" user-tag)
                          user-tag
                        (concat "*sql--" user-tag "*"))))
    (setq-local z-output-buffer-for-buffer buffer-name)))

(setq z-python-exec-sqlite-sql (concat "sqlite3 ${db} < .tmp_code.sql"))

(defun z-dql-sqlite (arg)
  "Returns a 2 length list representing the bounds for
   either the entire buffer or the REGION"
  (interactive "P")
  ;; not ideal to reset both at the same time, but okay for now
  (z-sqlite-set-dbfile arg)
  (z-set-async-output-buffer-for-buffer arg)
  (let ((bounds (if (use-region-p)
                    (cons (region-beginning) `(,(region-end)))
                  (cons (point-at-bol) `(,(point-at-eol))))))
    (write-region (nth 0 bounds) (nth 1 bounds) "./.tmp_code.sql" nil)
    (async-shell-command (s-format z-python-exec-sqlite-sql 'aget `(("db" . ,z-sqlite-dbfile))) z-output-buffer-for-buffer)))
