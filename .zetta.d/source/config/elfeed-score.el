(use-package elfeed-score
  :ensure (elfeed-score :type git :host github :repo "sp1ff/elfeed-score")
  :after elfeed-org
  :config
  (progn
    (elfeed-score-enable)
    (define-key elfeed-search-mode-map "=" elfeed-score-map))
  (setq elfeed-search-print-entry-function #'elfeed-score-print-entry)
  (message "loaded elfeed score")

  ;; NOTE overriding the fn - probably shouldn't live here since this
  ;; could entail features introduced by other packages, but remember
  ;; there are issues loading all the elfeed stuff from 1 file
  (defun elfeed-score-print-entry (entry)
    "Print ENTRY to the Elfeed search buffer.
This implementation is derived from `elfeed-search-print-entry--default'."
    (let* ((date (elfeed-search-format-date (elfeed-entry-date entry)))
           (title (or (elfeed-meta entry :title) (elfeed-entry-title entry) ""))
           (title-faces (elfeed-search--faces (elfeed-entry-tags entry)))
           (feed (elfeed-entry-feed entry))
           (feed-title
            (when feed
              (or (elfeed-meta feed :title) (elfeed-feed-title feed))))
           (tags (mapcar #'symbol-name (elfeed-entry-tags entry)))
           (tags-str (mapconcat
                      (lambda (s) (propertize s 'face 'elfeed-search-tag-face))
                      tags ","))
           (title-width (- (window-width) 10 elfeed-search-trailing-width))
           (title-column (elfeed-format-column
                          title (elfeed-clamp
                                 elfeed-search-title-min-width
                                 title-width
                                 elfeed-search-title-max-width)
                          :left))
	       (score
            (elfeed-score-format-score
             (elfeed-score-scoring-get-score-from-entry entry))))
      (insert score)
      (insert (propertize title-column 'face title-faces 'kbd-help title) " ")
      (when feed-title
        (insert (propertize feed-title 'face 'elfeed-search-feed-face) " "))
      (when tags
        (insert "(" tags-str ")"))
      (insert " ")
      (insert (propertize date 'face 'font-lock-comment-face) " ")
      ))

  (defun elfeed-score-sort (a b)
    "Return non-nil if A should sort before B.

`elfeed-score' will substitute this for the Elfeed scoring function."

    (let ((a-score (elfeed-score-scoring-get-score-from-entry a))
          (b-score (elfeed-score-scoring-get-score-from-entry b)))
      (if (> a-score b-score)
          t
        (let ((a-date (elfeed-entry-date a))
              (a-title (elfeed-entry-title a))
              (b-date (elfeed-entry-date b))
              (b-title (elfeed-entry-title b))
              )
          (and
           (eq a-score b-score)
           (> a-date b-date)
           (string> a-title b-title)
           )))))


  :general
  (
   :states '(normal)
   :keymaps '(elfeed-search-mode-map)
   "x" 'elfeed-score-explain))
