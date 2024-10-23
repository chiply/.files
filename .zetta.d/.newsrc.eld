;; -*- mode:emacs-lisp; coding: utf-8-emacs; -*-
;; Gnus startup file.
;; Never delete this file -- if you want to force Gnus to read the
;; .newsrc file (if you have one), touch .newsrc instead.
(setq gnus-newsrc-file-version "Gnus v5.13")

(setq gnus-newsrc-last-checked-date '"Tue, 22 Oct 2024 20:18:02 -0400")

(setq gnus-newsrc-alist '(("nndraft:drafts" 1 nil nil (nndraft "") ((gnus-dummy (gnus-draft-mode)))) ("nnrss:NYT > World News" 3 ((1 . 71)) ((unexist) (seen (1 . 71))) (nnrss "")) ("nntp+news.gmane.io:gwene.com.newyorker" 3 (10598 (10605 . 10605)) ((unexist) (seen (10596 . 10605))) "nntp:news.gmane.io") ("nntp+news.gmane.io:gwene.com.xkcd" 3 ((1 . 5) (2244 . 2245)) ((unexist) (seen (1 . 2245))) "nntp:news.gmane.io") ("nntp+news.gmane.io:gwene.com.xkcdexplained" 3 ((38 . 38)) ((unexist) (seen (1 . 38))) "nntp:news.gmane.io") ("nntp+news.gmane.io:gwene.no.ingebrigtsen.lars" 3 (1 3382 3384 (3397 . 3397)) ((unexist) (seen (1 . 3397))) "nntp:news.gmane.io")))

(setq gnus-server-alist '(("archive" nnfolder "archive" (nnfolder-directory "~/Mail/archive") (nnfolder-active-file "~/Mail/archive/active") (nnfolder-get-new-mail nil) (nnfolder-inhibit-expiry t))))
