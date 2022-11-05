(use-package text-mode
  :straight nil
  :demand t
  :hook (text-mode . (lambda () (toggle-truncate-lines 1)))
 )
