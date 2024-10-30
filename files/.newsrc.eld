;; -*- mode:emacs-lisp; coding: utf-8-emacs; -*-
;; Gnus startup file.
;; Never delete this file -- if you want to force Gnus to read the
;; .newsrc file (if you have one), touch .newsrc instead.
(setq gnus-newsrc-file-version "Gnus v5.13")

(setq gnus-newsrc-options '"")

(setq gnus-newsrc-last-checked-date '"Wed, 30 Oct 2024 18:44:44 -0400")

(setq gnus-newsrc-alist '(("nndraft:drafts" 1 nil nil (nndraft "") ((gnus-dummy (gnus-draft-mode)))) ("nntp+news.gmane.io:gwene.bbc.news.world" 3 ((1 . 65712)) ((unexist) (seen (65472 . 65473) (65506 . 65712))) "nntp:news.gmane.io") ("nntp+news.gmane.io:gwene.com.xkcd" 3 ((1 . 2248)) ((unexist) (seen (2236 . 2245) (2247 . 2248))) "nntp:news.gmane.io")))

(setq gnus-server-alist '(("archive" nnfolder "archive" (nnfolder-directory "~/Mail/archive") (nnfolder-active-file "~/Mail/archive/active") (nnfolder-get-new-mail nil) (nnfolder-inhibit-expiry t))))

(setq gnus-zombie-list '("nntp+news.gmane.io:gwene.co.usermag" "nntp+news.gmane.io:gwene.com.amazon.aws.blogs.containers" "nntp+news.gmane.io:gwene.com.hashicorp.blog" "nntp+news.gmane.io:gwene.de.tagesschau.infoservices.alle-meldungen" "nntp+news.gmane.io:gwene.org.trescom" "nntp+news.gmane.io:gwene.it.ariis.stream" "nntp+news.gmane.io:gwene.com.youtube.feeds.videos.xml.channel.inigo.quilez"))
