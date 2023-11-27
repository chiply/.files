;;; z-tree-sitter.el --- Extension for tree-sitter -*- lexical-binding: t -*-


;;; Code:
(setq tree-sitter-debug-highlight-jump-region t)
(setq tree-sitter-debug-jump-buttons t)

(add-hook
 'python-ts-mode-hook
 (lambda () (progn (tree-sitter-mode) (tree-sitter-hl-mode))))


;;;###autoload
(defun z-tree-sitter-test ()
  (interactive)
  (message "goobar"))


(provide 'z-tree-sitter)
;;; z-tree-sitter.el ends here
