(defun z-load-extension-file (file)
  (interactive)
  "Load a file in current user's configuration directory"
  (message file)
  (let* ((emacsdir (expand-file-name user-emacs-directory))
         (sourcefile-path (format "%ssource/z-lisp/%s" emacsdir file))
         (file-extension (file-name-extension file))
         (root (file-name-sans-extension file))
         )
    (cond
     ((string= "el" file-extension)
      (load-file sourcefile-path))
     ((string= "org" file-extension)
      (let* ((tanglefile-path (format "%sconfig/tangled/%s.el" emacsdir root)))
        (org-babel-tangle-file sourcefile-path tanglefile-path)
        (load-file tanglefile-path)
        ))
     )
    )
  )

(defun z-load-extension-file (file)
  (interactive)
  "Load a file in current user's configuration directory"
  (message file)
  (let* ((emacsdir (expand-file-name user-emacs-directory))
         (sourcefile-path (format "%ssource/z-lisp/%s" emacsdir file))
         (file-extension (file-name-extension file))
         (root (file-name-sans-extension file))
         )
    (cond
     ((string= "el" file-extension)
      (load-file sourcefile-path))
     ((string= "org" file-extension)
      (let* ((tanglefile-path (format "%sconfig/tangled/%s.el" emacsdir root)))
        (org-babel-tangle-file sourcefile-path tanglefile-path)
        (load-file tanglefile-path)
        ))
     )
    )
  )

(defun z-load-config-file (file)
  (interactive)
  "Load a file in current user's configuration directory"
  (message file)
  (let* ((emacsdir (expand-file-name user-emacs-directory))
         (sourcefile-path (format "%ssource/config/%s" emacsdir file))
         (file-extension (file-name-extension file))
         (root (file-name-sans-extension file))
         )
    (cond
     ((string= "el" file-extension)
      (load-file sourcefile-path))
     ((string= "org" file-extension)
      (let* ((tanglefile-path (format "%sconfig/tangled/%s.el" emacsdir root)))
        (org-babel-tangle-file sourcefile-path tanglefile-path)
        (load-file tanglefile-path)
        ))
     )
    )
  )

(defun z-general-describe-keybindings (&optional arg)
  "Show all keys that have been bound with general in an org buffer.
Any local keybindings will be shown first followed by global keybindings.
With a non-nil prefix ARG only show bindings in active maps."
  (interactive "P")
  (with-output-to-temp-buffer "*General Keybindings*"
    (let* ((keybindings (append
                         (copy-alist general-keybindings)
                         (list (cons 'local general-local-keybindings))))
           (active-maps (current-active-maps)))
      ;; print prioritized keymaps first (if any)
      (dolist (keymap general-describe-priority-keymaps)
        (let ((keymap-cons (assq keymap keybindings)))
          (when (and keymap-cons
                     (or (null arg)
                         (and (boundp (car keymap-cons))
                              (memq (symbol-value (car keymap-cons))
                                    active-maps))))
            (general--print-keymap-heading keymap-cons)
            (setq keybindings (assq-delete-all keymap keybindings)))))
      ;; sort the remaining and then print them
      (when general-describe-keymap-sort-function
        (setq keybindings (funcall general-describe-keymap-sort-function
                                   keybindings)))
      (dolist (keymap-cons keybindings)
        (when (or (null arg)
                  (and (boundp (car keymap-cons))
                       (memq (symbol-value (car keymap-cons)) active-maps)))
          (general--print-keymap-heading keymap-cons)))))

  (with-current-buffer "*General Keybindings*"
    (write-region
     (point-min)
     (point-max)
     "~/.files/.zetta.d/keybindings.org"
     t)
    (kill-buffer)
    )
  )


;; build docs
(defun z-build-docs ()
  (interactive)
  (with-current-buffer (find-file-noselect "~/.files/.zetta.d/read.org")
    (org-babel-execute-buffer) 
    (save-buffer)
    (org-open-file (org-html-export-to-html))
    (kill-buffer)
    )
  )


(defun z-foobar (func)
  (with-current-buffer (get-buffer-create "*z-tmp-autodoc*")
    (condition-case nil
        (pp-emacs-lisp-code (symbol-function func))
      (error nil)
      )
    (setq elisp-code (buffer-substring
                      (save-excursion (beginning-of-buffer) (point))
                      (save-excursion (end-of-buffer) (point))
                      ))
    )
  (kill-buffer "*z-tmp-autodoc*")
  elisp-code
  )



(defun z-docs-from-extension (ext)
  (let* ((fname (expand-file-name
                 (format "source/extension/%s.el" ext)
                 user-emacs-directory))
         (elements (cdr
                    (assoc
                     fname
                     load-history)))
         (vars (-filter 'symbolp elements))
         (funcons (-filter (lambda (x)
                             (and (consp x)
                                  (eq 'defun (car x))))
                           elements))
         (funcs (mapcar 'cdr funcons)))
    (switch-to-buffer "*org-doc*")
    (erase-buffer)
    (insert (format "#+TITLE: Documentation for %s
#+OPTIONS: toc:nil
" fname))
    (insert "* Variables\n")
    (dolist (var (sort vars 'string-lessp))
      (insert (format "** %s
Documentation: %s\n\n" var  (documentation-property var 'variable-documentation))))

    (insert "* Functions\n\n")
    
    (dolist (funcs (sort funcs 'string-lessp))
      
      ;;(kill-buffer "*z-tmp-autodoc*")

      (progn
        
        (insert (format "** %s %s
Documentation: %s

Code:
#+BEGIN_SRC emacs-lisp
%s
#+END_SRC
"
                        funcs
                        (or (help-function-arglist funcs) "")
                        (documentation funcs)
                        (z-foobar funcs))

                )))
    (org-mode)
    (write-file (format "%s-doc.org" ext))
                                        ;(org-export-to-file 'latex "jmax-bibtex-doc.tex")
                                        ;(org-latex-compile "jmax-bibtex-doc.tex")
    (kill-buffer (format "%s-doc.org" ext))
    ))


;; TODO doesn't belong here as its specific to a dagster project....
;; might need to put this and the hooking stuff into private
(defun z-highlight-phrases ()
  (interactive)
  (message "HOOK RAN")
  (highlight-phrase "WARNING" 'modus-themes-intense-yellow)
  (highlight-phrase "STEP_SUCCESS" 'modus-themes-subtle-green)
  (highlight-phrase "PIPELINE_SUCCESS" 'modus-themes-intense-green)
  (highlight-phrase "ERROR" 'error)
  (highlight-phrase "HOOK_ERRORED" 'modus-themes-subtle-red)
  (highlight-phrase "New Records" 'modus-themes-subtle-blue)

  (highlight-phrase "COMMIT" 'modus-themes-subtle-red)
  (highlight-phrase "ROLLBACK" 'modus-themes-red-nuanced)
  (highlight-phrase "SELECT" 'modus-themes-subtle-blue)

  (highlight-phrase "INSERT" 'modus-themes-subtle-green)
  (highlight-phrase "UPDATE" 'modus-themes-subtle-green)
  (highlight-phrase "DELETE" 'modus-themes-subtle-green)

  (highlight-phrase "400" 'modus-themes-subtle-red)
  (highlight-phrase "401" 'modus-themes-subtle-red)
  (highlight-phrase "402" 'modus-themes-subtle-red)

  (highlight-phrase "404" 'modus-themes-subtle-red)

  (highlight-phrase "422" 'modus-themes-subtle-magenta)

  (highlight-phrase "500" 'modus-themes-intense-red)

  (highlight-phrase "200" 'modus-themes-subtle-green)
  (highlight-phrase "201" 'modus-themes-subtle-green)
  )


(defun z-touch-maybe (path)
  "touches the file if it doesn't already exist."
  (if (not (file-exists-p path))
      (if (string-match-p
           (regexp-quote ".")
           (nth 0 (last (split-string path "/"))))
          ;; it's a file, so touch
          (progn
            (message (shell-command-to-string (concat "touch " path)))
            (message (concat "touch " path))
            )
        ;; it's a dir, so mkdir
        (progn
          (message (shell-command-to-string (concat "mkdir " path)))
          (message (concat "mkdir " path))
          )
        )
    (message (concat "{" path "} already exists")))
  )

;; leaves all but last dir
(defun z-minify-path (path)
  (let* ((path (abbreviate-file-name path))
         (path-split (split-string path "/"))
         (leaf-dir-name (car (last path-split 2)))
         (path-split (butlast path-split 2))
         )
    (concat
     (mapconcat
      (lambda (s) (if (> (length s) 1) (substring s 0 2) (substring s 0 1)))
      path-split "/")
     "/" leaf-dir-name)))

(provide 'bootstrap-zettafn)



