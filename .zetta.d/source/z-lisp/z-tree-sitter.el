;;; z-tree-sitter.el --- Extension for tree-sitter -*- lexical-binding: t -*-


;;; Code:

(add-hook
 'python-mode-hook
 (lambda () (progn (tree-sitter-mode) (tree-sitter-hl-mode))))

;;;###autoload
(defun z-tree-sitter-test ()
  (interactive)
  (message "goobar"))


(provide 'z-tree-sitter)
;;; z-tree-sitter.el ends here
