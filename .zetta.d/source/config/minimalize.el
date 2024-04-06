(setq ns-use-proxy-icon nil
      frame-resize-pixelwise t
      ring-bell-function 'ignore
      inhibit-startup-message t
      make-backup-files nil
      auto-save-default nil
      indicate-empty-lines t
      kill-buffer-query-functions
      (delq
       'process-kill-buffer-query-function
       kill-buffer-query-functions))

(add-to-list 'default-frame-alist
             '(ns-transparent-titlebar . nil))

(dolist (x '((ns-transparent-titlebar . unbound)
             (ns-appearance . unbound)))
  (add-to-list 'frameset-filter-alist x))

(menu-bar-mode 1)
(tool-bar-mode 1)
(horizontal-scroll-bar-mode 1)
(scroll-bar-mode 1)
(fset 'yes-or-no-p 'y-or-n-p)

(setq blink-cursor-mode nil)

(setq frame-title-format
      '((:eval
         (or
          (when (and (boundp 'evil-mode) evil-mode) "🐍")
          (when (and (boundp 'meow-mode) meow-mode) "😼")
          (when (not (or (and (boundp 'evil-mode) evil-mode)
                         (and (boundp 'meow-mode) meow-mode))) "🦬")))
        (:eval
         (or
          (when (or (and (boundp 'meow-insert-mode) meow-insert-mode)
                    (and (boundp 'evil-insert-state-minor-mode) evil-insert-state-minor-mode))
            "🖋")
          (when (and
                 ;; in either evil or meow
                 (or (and (boundp 'evil-mode) evil-mode)
                     (and (boundp 'meow-mode) meow-mode))
                 ;; and insert state is not active
                 (not (or (and (boundp 'meow-insert-mode) meow-insert-mode)
                          (and (boundp 'evil-insert-state-minor-mode) evil-insert-state-minor-mode))))
            "🔏")))
        " "
        ;;; add recursion level indicator
        (:eval
         (let ((recursion-level (minibuffer-depth)))
           (if (zerop recursion-level)
               "[R:0]"
             (format " [R:%d]" recursion-level))))
        " "
        (:eval (st-modeline-lighter))
        "  "
        (:eval (if (buffer-file-name) (abbreviate-file-name (buffer-file-name)) "%b"))))



