(use-package elfeed-protocol
  :ensure (elfeed-protocol :type git :host github :repo "fasheng/elfeed-protocol")
  :after elfeed
  :config
  (setq elfeed-use-curl t)
  (elfeed-set-timeout 36000)
  (setq elfeed-curl-extra-arguments '("--insecure"))
  
  (setq elfeed-protocol-fever-update-unread-only nil)
  (setq elfeed-protocol-fever-fetch-category-as-tag t)
  (setq elfeed-protocol-feeds '(("fever+https://redacted@reader.miniflux.app"
                                 :api-url "https://reader.miniflux.app/fever/"
                                 :password "Emaj7#13")))


  (setq elfeed-protocol-enabled-protocols '(fever))
  (elfeed-protocol-enable)
  (message "loaded elfeed protocol")
  )
