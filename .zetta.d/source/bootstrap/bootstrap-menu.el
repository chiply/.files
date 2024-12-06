;;; -*- lexical-binding: t -*-

(use-package menu
  :ensure nil
  :demand t
  :load-path "~/.files/.zetta.d/source/zettapkg/menu"
  :after which-key
  :config

  ;; note making this t requires you to 'quit' the which key window
  ;; before opening embark if C-h is used... not a clear side-effect,
  ;; so documenting here.  I want to keep the option open to have both.
  ;; only way around this is to rebind C-h in the default menus-map
  (setq which-key-use-C-h-commands t)

  (defmacro defmenu+ (name map key)
    "Personal function that runs defmenu and also binds the menu to a prefix
key that is available in many contexts"
    `(progn
       (defmenu ,name ,map)
       ;; TODO add meow
       (general-define-key :keymaps 'launch-map
                           ,key ',name)
       (general-define-key :keymaps '(evil-insert-state-map)
                           (general-chord ,(concat "," key)) ',name)
       (general-define-key :keymaps 'override :states '(normal visual)
                           :prefix ","
                           ,key ',name)))

  (defmenu+ menu-window menu-window-keymap "w")
  (defmenu+ menu-project menu-project-keymap "p")
  (defmenu+ menu-run menu-run-keymap "r")
  (defmenu+ menu-org menu-org-keymap "o")

  ;; TODO move to magit -- not used here
  (defmenu+ menu-vc menu-vc-keymap "g")

  (setq prefix-help-command 'versatile-C-h))

(provide 'bootstrap-menu)
