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
  (setq browse-url-handlers
        '(("https:\\/\\/www\\.youtu\\.*be." . browse-url-mpv)))

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





