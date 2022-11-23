(use-package browse-url
  :straight nil
  :demand t
  :config
  (setq
   browse-url-handlers
   '(
     ("https:\\/\\/www\\.youtu\\.*be." . browse-url-mpv)
     ("." . eaf-open-browser)
     ))
  )
