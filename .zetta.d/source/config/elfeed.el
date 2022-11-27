;; -*- lexical-binding: t -*-

(use-package elfeed
  :init


  (defun elfeed-tag-selection-as (mytag)
    "Returns a function that tags an elfeed entry or selection as MYTAG"
    (lambda ()
      "Toggle a tag on an Elfeed search selection"
      (interactive)
      (elfeed-search-toggle-all mytag)))

  (defun prot-common-crm-exclude-selected-p (input)
    "Filter out INPUT from `completing-read-multiple'.
Hide non-destructively the selected entries from the completion
table, thus avoiding the risk of inputting the same match twice.

To be used as the PREDICATE of `completing-read-multiple'."
    (if-let* ((pos (string-match-p crm-separator input))
              (rev-input (reverse input))
              (element (reverse
                        (substring rev-input 0
                                   (string-match-p crm-separator rev-input))))
              (flag t))
        (progn
          (while pos
            (if (string= (substring input 0 pos) element)
                (setq pos nil)
              (setq input (substring input (1+ pos))
                    pos (string-match-p crm-separator input)
                    flag (when pos t))))
          (not flag))
      t))


  (defun prot-elfeed--format-tags (tags sign)
    "Prefix SIGN to each tag in TAGS."
    (mapcar (lambda (tag)
              (format "%s%s" sign tag))
            tags))

  (defun prot-elfeed-search-tag-filter ()
    "Filter Elfeed search buffer by tags using completion.

Completion accepts multiple inputs, delimited by `crm-separator'.
Arbitrary input is also possible, but you may have to exit the
minibuffer with something like `exit-minibuffer'."
    (interactive)
    (unwind-protect
        (elfeed-search-clear-filter)
      (let* ((elfeed-search-filter-active :live)
             (db-tags (elfeed-db-get-all-tags))
             (plus-tags (prot-elfeed--format-tags db-tags "+"))
             (minus-tags (prot-elfeed--format-tags db-tags "-"))
             (all-tags (delete-dups (append plus-tags minus-tags)))
             (tags (completing-read-multiple
                    "Apply one or more tags: "
                    all-tags #'prot-common-crm-exclude-selected-p t))
             (input (string-join `(,elfeed-search-filter ,@tags) " ")))
        (setq elfeed-search-filter input))
      (elfeed-search-update :force)))


  :config

  (defun elfeed-search-format-date (date)
    (format-time-string "%Y-%m-%d %H:%M" (seconds-to-time date)))


  (setq browse-url-generic-program nil)
  
  (defun elfeed-show-eww-open (&optional use-generic-p)
    "open with eww"
    (interactive "P")
    (let ((browse-url-browser-function #'eww-browse-url))
      (elfeed-show-visit use-generic-p)))

  (defun elfeed-search-eww-open (&optional use-generic-p)
    "open with eww"
    (interactive "P")
    (let ((browse-url-browser-function #'eww-browse-url))
      (elfeed-search-browse-url use-generic-p)))

  ;; doesn't really work

  (defun browse-url-mpv (url &optional single)
    ;; LEFT OFF - replace this function? use vterm, async has problems running mpv
    (start-process "mpv" "*mpv*" "mpv" (shell-quote-argument url))
    )


  (defun z-shr-browse-url ()
    (interactive)
    (let ((browse-url-browser-function 'browse-url-default-browser))
      (call-interactively 'shr-browse-url)
      )
    )

  :general
  (
   :states '(normal)
   :keymaps '(elfeed-show-mode-map)
   "C-c C-S-o" 'z-org-open-at-point
   "C-c C-o" 'org-open-at-point
   "B" 'elfeed-show-eww-open
   )
  (
   :states '(normal)
   :keymaps '(elfeed-search-mode-map)
   "t" 'prot-elfeed-search-tag-filter
   ;; quick tags
   "l" (elfeed-tag-selection-as 'readlater)
   "d" (elfeed-tag-selection-as 'junk)
   "B" 'elfeed-search-eww-open
   "r" 'elfeed-search-untag-all-unread
   "R" 'elfeed-search-tag-all-unread
   )
  )

(use-package elfeed-score
  :after elfeed
  :config
  (progn
    (elfeed-score-enable)
    (define-key elfeed-search-mode-map "=" elfeed-score-map))
  (setq elfeed-search-print-entry-function #'elfeed-score-print-entry)

  :display
  (z-side "^\\*elfeed-score-explanations*" 'bottom)

  :general
  (
   :states '(normal)
   :keymaps '(elfeed-search-mode-map)
   "x" 'elfeed-score-explain
   )
  )


(use-package elfeed-tube
  :config
  (elfeed-tube-setup)

  :general
  (
   :states '(normal)
   :keymaps '( elfeed-show-mode-map)
   "F" 'elfeed-tube-fetch
   "C-s" 'elfeed-tube-save
   )
  )



(use-package elfeed-summary
  :config
  (setq
   elfeed-summary-settings
   '(
     (group
      (:title . "All")
      (:elements
       (search (:filter . "@12-months-ago") (:title . "All"))
       )
      (:hide nil))

     (group
      (:title . "Reading List")
      (:elements
       (search (:filter . "@12-months-ago +readlater") (:title . "All"))
       (query . (and readlater))
       )
      (:hide nil))

     ;; News
     (group
      (:title . "News")
      (:elements
       (search (:filter . "@12-months-ago +news") (:title . "All"))
       (query . (and news))
       )
      (:hide nil))

     ;; Tweets
     (group
      (:title . "Tweets")
      (:elements
       (search (:filter . "@12-months-ago +tweets") (:title . "All"))
       (query . (and tweets))
       )
      (:hide nil))

     ;; Reddit
     (group
      (:title . "Reddit")
      (:elements
       (search (:filter . "@12-months-ago +reddit") (:title . "All"))
       (query . (and reddit))
       )
      (:hide nil))
     


     ;; Podcasts
     (group
      (:title . "podcasts")
      (:elements
       (search (:filter . "@12-months-ago +podcast") (:title . "All"))
       (query . (and podcast))
       )
      (:hide nil))


     ;; Youtube
     (group
      (:title . "Youtube")
      (:elements
       (search (:filter . "@12-months-ago +youtube") (:title . "All"))
       (group (:title . "Industry") (:elements (query . (and youtube industry))) (:hide nil))
       (group (:title . "Tech") (:elements (query . (and youtube technology))) (:hide nil))
       (group (:title . "Math") (:elements (query . (and youtube math))) (:hide nil))
       (group (:title . "Science") (:elements (query . (and youtube science))) (:hide nil))
       )
      (:hide nil))

     ;; release notes
     (group
      (:title . "AWS Docs")
      (:elements
       (search (:filter . "@12-months-ago +release_notes") (:title . "All"))
       (query . (and release_notes))
       )
      (:hide nil))

     ;; AWS Blogs
     (group
      (:title . "AWS Blogs")
      (:elements
       (search (:filter . "@12-months-ago +aws +blog") (:title . "All"))
       (query . (and aws blog))
       )
      (:hide nil))

     ;; Dataengineering
     (group
      (:title . "dataengineering")
      (:elements
       (search (:filter . "@12-months-ago +dataengineering") (:title . "All"))
       (query . (and dataengineering))
       )
      (:hide nil))

     ;; Dagster
     (group
      (:title . "dagster")
      (:elements
       (search (:filter . "@12-months-ago +dagster") (:title . "All"))
       (query . (and dagster))
       )
      (:hide nil))

     ;; python
     (group
      (:title . "python")
      (:elements
       (search (:filter . "@12-months-ago +python") (:title . "All"))
       (query . (and python))
       )
      (:hide nil))

     ;; faang_blog
     (group
      (:title . "faang_blog")
      (:elements
       (search (:filter . "@12-months-ago +faang_blog") (:title . "All"))
       (query . (and faang_blog))
       )
      (:hide nil))

     ;; Emacs
     (group
      (:title . "Emacs")
      (:elements
       (search (:filter . "@12-months-ago +emacs") (:title . "All tagged"))
       (search (:filter . "@12-months-ago emacs") (:title . "All mentions"))
       (query . (and emacs))
       )
      (:hide nil))
     
     ;; Medrxiv
     (group
      (:title . "medrxiv")
      (:elements
       (search (:filter . "@12-months-ago +medrxiv") (:title . "All"))
       (query . (and medrxiv))
       )
      (:hide nil))

     ;; arxiv
     (group
      (:title . "arxiv")
      (:elements
       (search (:filter . "@12-months-ago +arxiv") (:title . "All"))
       (query . (and arxiv))
       )
      (:hide nil))

     ;; Datascience
     (group
      (:title . "datascience")
      (:elements
       (search (:filter . "@12-months-ago +datascience") (:title . "All"))
       (query . (and datascience))
       )
      (:hide nil))


     ;; Comics
     (group
      (:title . "Funnies")
      (:elements
       (search (:filter . "@12-months-ago +comic") (:title . "All"))
       (search (:filter . "@12-months-ago +comic +dilbert") (:title . "Dilbert"))
       (search (:filter . "@12-months-ago +comic +xkcd") (:title . "xkcd"))
       )
      (:hide nil))

     ;; Ungrouped
     (group
      (:title . "Ungrouped")
      (:elements :misc)
      (:hide t))

     )))
