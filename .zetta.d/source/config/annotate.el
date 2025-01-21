(use-package annotate
  :config

  ;; test annotation


  ;; NOTE annotations could be on possibly private data, but would be
  ;; ideal to sync annotations for things like `.files` (via github)
  ;; or personal notes (via logseq).  To accomplish this, need to set
  ;; `annotation-file` variable per directory (can be done via
  ;; dir-locals.el - note logseq doesn't sync the dir-locals or
  ;; annotations flie.  Need to explicitly set the .dir-locals on each
  ;; machine and to make annotations havea .org suffix for annotations
  ;; to get synced)
  ;; (setq annotate-file "~/annotations")
  
  ;; NOTE This solves the problem of syncing public vs private... keep
  ;; in mind the alternative .dir-locals + annotations approach was
  ;; not working!
  (setq annotate-file-buffer-local t)
  (setq annotate-buffer-local-database-extension "annotations.org")
  ;; otherwise you get alignment issues
  (setq annotate-annotation-column 0)
  ;; NOTE doesn't seem to use all colors
  (setq
   annotate-highlight-faces
   '((:background "#EEF192")
     (:background "#92EEF1")
     (:background "#F192EE")
     (:background "#F19292")
     (:background "#92F192")
     (:background "#9292F1")
     (:background "#F1F192")
     (:background "#F192F1")
     (:background "#92F1F1")
     (:background "#F1F1F1")
     ))

  (setq
   annotate-annotation-text-faces
   `((:background "#EEF192" :underline t) 
     (:background "#92EEF1" :underline t) 
     (:background "#F192EE" :underline t)
     (:background "#F19292" :underline t)
     (:background "#92F192" :underline t)
     (:background "#9292F1" :underline t)
     (:background "#F1F192" :underline t)
     (:background "#F192F1" :underline t)
     (:background "#92F1F1" :underline t)
     (:background "#F1F1F1" :underline t)))

  ;; NOTE may be missing bindings for meow

  ;; NOTE when adding text, need to re-save annotations using
  ;; `annotate-save-annotations`, otherwise adding text corrupts the
  ;; data
  :general
  (
   :keymaps '(markdown-mode-map org-mode-map prog-mode-map)
   :states '(normal visual insert)
   "C-s" (lambda () (interactive)
           (when (bound-and-true-p annotate-mode)
             (annotate-save-annotations))
           (save-buffer))
   )
  (
   :keymaps 'menu-window-keymap
   "a" 'annotate-mode
   )

  ;; TODO add embark general binding for annotate

  ;; TODO add autosave hook to ensure annotations are being saved if
  ;; autosaved?

  ;; TODO something to ensure annotations are saved whenever an
  ;; annotation is added? or will i simply have to remember this

  :hook ((markdown-mode org-mode prog-mode) . annotate-mode))
