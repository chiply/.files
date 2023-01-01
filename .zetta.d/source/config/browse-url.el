(use-package browse-url
  :straight nil
  :demand t
  :config
  (setq
   browse-url-handlers
   '(
     ;; urls that cannot render fully in eww
     ("youtube.com" . eaf-open-browser)
     ("github.com" . eaf-open-browser)
     ("melpa.org" . eaf-open-browser)
     ;; gives really nice hotswitching to view html files while
     ;; working on them
     ("^.+.html" . eaf-open-browser)
     ;; everything else, use eww-browse-url
     ("." . eww-browse-url)
     ))
  )


