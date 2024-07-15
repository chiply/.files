(use-package casual-suite
  :config
  (define-key calc-mode-map (kbd "C-o") #'casual-calc-tmenu)
  (define-key dired-mode-map (kbd "C-o") #'casual-dired-tmenu)
  (define-key info-mode-map (kbd "C-o") #'casual-info-tmenu)
  (keymap-global-set "M-g" #'casual-avy-tmenu)
  (define-key isearch-mode-map (kbd "<f2>") #'casual-isearch-tmenu))

