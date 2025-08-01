(use-package all-the-icons
  :ensure t
  :straight (all-the-icons
             :type git
             :host github
             :repo "domtronn/all-the-icons.el"
             :branch "svg"
             :files (:defaults "svg"))
  :if (display-graphic-p)
  :config
  ;;(use-package octicons)
  (setq all-the-icons-color-icons t)

  ;; fixing themes
  ;; TODO mayybe more efficient way to just add a face to this
  ;; Somehow this gets araound teh size problem
  (setq all-the-icons-mode-icon-alist
        (-remove
         (lambda (x)
           (or (eq (car x) 'vterm-mode)
               (eq (car x) 'copilot-mode)
               (eq (car x) 'lsp-mode)
               (eq (car x) 'evil-state)
               (eq (car x) 'meow-state)
               (eq (car x) 'emacs-state)
               (eq (car x) 'insert-state)
               (eq (car x) 'non-insert-state)))
         all-the-icons-mode-icon-alist))
  (add-to-list 'all-the-icons-mode-icon-alist '(vterm-mode octicons "terminal" :face all-the-icons-dired-dir-face))
  (add-to-list 'all-the-icons-mode-icon-alist '(copilot-mode octicons "copilot" :face all-the-icons-dired-dir-face))
  (add-to-list 'all-the-icons-mode-icon-alist '(lsp-mode fileicon "vscode" :face all-the-icons-dired-dir-face))
  (add-to-list 'all-the-icons-mode-icon-alist '(evil-state devopicons "vim" :face all-the-icons-dired-dir-face))
  (add-to-list 'all-the-icons-mode-icon-alist '(meow-state fluentui-system-icons "animal_cat" :face all-the-icons-dired-dir-face))
  (add-to-list 'all-the-icons-mode-icon-alist '(emacs-state fileicon "emacs" :face all-the-icons-dired-dir-face))
  (add-to-list 'all-the-icons-mode-icon-alist '(insert-state fluentui-system-icons "pen" :face all-the-icons-dired-dir-face))
  (add-to-list 'all-the-icons-mode-icon-alist '(non-insert-state fluentui-system-icons "pen_off" :face all-the-icons-dired-dir-face))
  )


