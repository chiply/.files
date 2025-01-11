;; inspired by https://medium.com/@evnbr/coding-in-color-3a6db2743a1e
(use-package color-identifiers-mode
  :config
  ;; NOTE need to add some modes
  (add-to-list 'color-identifiers:modes-alist
               '(python-ts-mode "\\(?:[^.]\\|^\\)[[:space:]]*"
                             "\\_<\\([a-zA-Z_$]\\(?:\\s_\\|\\sw\\)*\\)"
                             (nil font-lock-variable-name-face
                                  tree-sitter-hl-face:variable)))
  (global-color-identifiers-mode))
