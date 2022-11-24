(use-package browse-url
  :straight nil
  :demand t
  :config
  (setq
   browse-url-handlers
   '(
     ("https:\\/\\/www\\.youtu\\.*be." . browse-url-mpv)
     ("github.com" . eaf-open-browser)
     ("." . eww-browse-url)
     ))
  )


(string-match "https://github.com" "https://github.com/skeeto/elfeed")
