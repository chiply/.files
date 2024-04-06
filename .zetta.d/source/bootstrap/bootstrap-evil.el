(use-package evil
  :demand t
  :init
  (setq evil-want-keybinding nil)
  (add-to-list
   'brushup-styles
   '(setq evil-emacs-state-cursor '("red" box)
          evil-visual-state-cursor '("orange" box)
          evil-insert-state-cursor '("blue" box)
          evil-replace-state-cursor '("green" hollow)
          evil-operator-state-cursor '("red" hollow)
          evil-normal-state-cursor `(,(face-attribute 'default :foreground) box)))

  :config
  (setq evil-default-state 'normal)

  ;; get emacs kbds in insert-mode
  (setcdr evil-insert-state-map nil)
  (define-key evil-insert-state-map (read-kbd-macro evil-toggle-key) 'evil-emacs-state)
  (define-key evil-insert-state-map (kbd "<escape>") 'evil-force-normal-state)  

  ;; this stuff is destined for the respective
  ;; use-package calls
  (evil-set-initial-state 'Info-mode 'normal)
  (evil-set-initial-state 'with-editor-mode 'emacs)
  (evil-set-initial-state 'eww-mode 'emacs)
  (evil-set-initial-state 'minimap-sb-mode 'emacs)
  (evil-set-initial-state 'minimap-mode 'emacs)

  (evil-mode 1)


  :general
  (
   :keymaps 'evil-insert-state-map
   (general-chord ",/") 'evil-ex-nohighlight
   )
  (
   :states '(normal visual)
   :keymaps 'override
   :prefix ","
   "/" 'evil-ex-nohighlight
   )
  (
   :states '(normal visual)
   "C-S-j" (lambda () (interactive) (evil-scroll-down nil))
   "C-S-k" (lambda () (interactive) (evil-scroll-up nil))
   "C-j" (lambda () (interactive) (evil-scroll-line-down 1))
   "C-k" (lambda () (interactive) (evil-scroll-line-up 1))
   )
  (
   :keymaps '(evil-insert-state-map evil-visual-state-map)
   (general-chord "kj") 'evil-normal-state
   (general-chord "jk") 'evil-normal-state
   )
  )


(defalias 'use-package-handler/:evil 'use-package-handle-forms)
(defalias 'use-package-normalize/:evil 'use-package-normalize-forms)

(add-to-list 'use-package-keywords :evil t)

(provide 'bootstrap-evil)

