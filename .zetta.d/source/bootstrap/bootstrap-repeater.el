;;; -*- lexical-binding: t -*-

(use-package menu
  :ensure nil
  :demand t
  :load-path "~/.files/.zetta.d/source/zettapkg/menu"
  :after which-key
  :config

  (setq which-key-use-C-h-commands nil)

  (defmacro defmenu+ (name map key)
    `(progn
       (defmenu ,name ,map)
       (general-define-key :keymaps 'launch-map ,key ',name)
       (general-define-key :keymaps '(evil-insert-state-map)
                           (general-chord ,(concat "," key)) ',name)
       (general-define-key :keymaps 'override
                           :states '(normal visual)
                           :prefix "," ,key ',name)))

  (defmenu+ menu-window menu-window-keymap "w")
  (defmenu menu-vc menu-vc-keymap "g"))


(provide 'bootstrap-menu)
