;; -*- mode:emacs-lisp; coding: utf-8-emacs; -*-
;; Gnus startup file.
;; Never delete this file -- if you want to force Gnus to read the
;; .newsrc file (if you have one), touch .newsrc instead.
(setq gnus-newsrc-file-version "Gnus v5.13")

(setq gnus-newsrc-options '"")

(setq gnus-newsrc-last-checked-date '"Wed, 06 Nov 2024 04:51:33 -0500")

(setq gnus-newsrc-alist '(("nndraft:drafts" 1 nil nil (nndraft "") ((gnus-dummy (gnus-draft-mode)))) ("nntp+news.gmane.io:gwene.bbc.news.world" 3 ((1 . 65908)) ((unexist) (seen (65472 . 65473) (65506 . 65908))) "nntp:news.gmane.io") ("nntp+news.gmane.io:gwene.com.feedburner.amazon.web.services.blog" 3 ((1 . 3494)) ((unexist) (seen (3483 . 3494))) "nntp:news.gmane.io") ("nntp+news.gmane.io:gwene.com.nytimes.rss.services.xml.rss.nyt.technology" 3 ((1 . 22027)) ((unexist) (seen (22015 . 22027))) "nntp:news.gmane.io") ("nntp+news.gmane.io:gwene.com.nytimes.services.xml.rss.nyt.science" 3 ((1 . 23255)) ((unexist) (seen (23231 . 23255))) "nntp:news.gmane.io") ("nntp+news.gmane.io:gwene.com.nytimes.services.xml.rss.nyt.us" 3 ((1 . 118242)) ((unexist) (seen (118050 . 118242))) "nntp:news.gmane.io") ("nntp+news.gmane.io:gwene.com.nytimes.services.xml.rss.nyt.world" 3 ((1 . 106069)) nil "nntp:news.gmane.io" nil) ("nntp+news.gmane.io:gwene.com.xkcd" 3 ((1 . 2251)) ((unexist) (seen (2236 . 2245) (2247 . 2251))) "nntp:news.gmane.io") ("nntp+news.gmane.io:gwene.org.npr" 3 ((1 . 145817)) ((unexist) (seen (145676 . 145817))) "nntp:news.gmane.io")))

(setq gnus-server-alist '(("archive" nnfolder "archive" (nnfolder-directory "~/Mail/archive") (nnfolder-active-file "~/Mail/archive/active") (nnfolder-get-new-mail nil) (nnfolder-inhibit-expiry t))))

(setq gnus-zombie-list '("nntp+news.gmane.io:gwene.org.alpinelinux" "nntp+news.gmane.io:gwene.com.clunyjournal" "nntp+news.gmane.io:gwene.bbc.news.england.manchester" "nntp+news.gmane.io:gwene.club.digdeeper" "nntp+news.gmane.io:gwene.com.erinkissane" "nntp+news.gmane.io:gwene.net.aastatus" "nntp+news.gmane.io:gwene.org.fedoraproject.communityblog" "nntp+news.gmane.io:gwene.com.youtube.pulpmortem" "nntp+news.gmane.io:gwene.co.usermag" "nntp+news.gmane.io:gwene.com.amazon.aws.blogs.containers" "nntp+news.gmane.io:gwene.com.hashicorp.blog" "nntp+news.gmane.io:gwene.de.tagesschau.infoservices.alle-meldungen" "nntp+news.gmane.io:gwene.org.trescom" "nntp+news.gmane.io:gwene.it.ariis.stream" "nntp+news.gmane.io:gwene.com.youtube.feeds.videos.xml.channel.inigo.quilez"))
