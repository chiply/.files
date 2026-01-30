; need t oadd auth too automatcially id in nickserv https://share.google/aimode/tTej5j2GHL0ohIOeR
(use-package erc
  :ensure nil
  :config
  (add-to-list 'erc-modules 'services)
  (setq erc-use-auth-source-for-nickserv-password t)
  (setq erc-prompt-for-nickserv-password nil)

  (setq erc-server "irc.libera.chat"
        erc-nick "charlieholland"
        erc-user-full-name "Charlie Holland"
        erc-track-shorten-start 8
        erc-track-showcount t
        ;; NOTE for the SERVER, look at tthe buffer name when you log
        ;; in.  this has to be (Libera.Chat), not "irc.libera.chat"
        erc-autojoin-channels-alist '((Libera.Chat "#systemcrafters" "#emacs" "##programming" "##math"))
        erc-kill-buffer-on-part t
        erc-auto-query 'bury)

  (setq erc-track-position-in-mode-line t)
  )
