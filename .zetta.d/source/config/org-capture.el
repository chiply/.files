;; -*- lexical-binding: t; -*-

;;; Searching logseq todo headings
;; Functions z-logseq-todo-files and related are defined in bootstrap-org.el

(defun z-logseq-search-headings ()
  "Search through headings in all logseq (todo) files using org-ql-find."
  (interactive)
  (let ((files (z-logseq-todo-files)))
    (if files
        (org-ql-find files)
      (message "No (todo) files found in %s" z-logseq-pages-dir))))

(defun z-logseq-search-todos ()
  "Search through TODO items in all logseq (todo) files."
  (interactive)
  (let ((files (z-logseq-todo-files)))
    (if files
        (org-ql-search files '(todo))
      (message "No (todo) files found in %s" z-logseq-pages-dir))))

(defun z-logseq-consult-headings ()
  "Search headings in logseq (todo) files using consult."
  (interactive)
  (let ((files (z-logseq-todo-files)))
    (if files
        (consult-org-heading nil files)
      (message "No (todo) files found in %s" z-logseq-pages-dir))))

;; Keybindings for logseq search commands
(general-define-key
 :keymaps 'launch-map
 :prefix "o"
 "s" 'z-logseq-search-headings
 "t" 'z-logseq-search-todos
 "h" 'z-logseq-consult-headings)
