(use-package tree-sitter
  :hook (python-mode . (lambda () (progn (tree-sitter-mode) (tree-sitter-hl-mode))))
  )

