(use-package browse-url
  :straight nil
  :demand t
  :config
  (setq
   browse-url-handlers
   '(
     ("youtube.com" . eaf-open-browser)
     ("github.com" . eaf-open-browser)
     ("melpa.org" . eaf-open-browser)
     ("." . eww-browse-url)
     ))
  )


