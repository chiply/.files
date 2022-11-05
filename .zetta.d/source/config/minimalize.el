(setq ns-use-proxy-icon nil
      frame-resize-pixelwise t
      ring-bell-function 'ignore
      inhibit-startup-message t
      make-backup-files nil
      auto-save-default nil
      indicate-empty-lines t
      kill-buffer-query-functions (delq 'process-kill-buffer-query-function kill-buffer-query-functions))

(add-to-list 'default-frame-alist
             '(ns-transparent-titlebar . nil))

(setq frame-title-format
      '(
        (:eval
         (propertize
          (format "%s|%s"
                  (car (car z-ws-alist))
                  (winds-get-cur-cfg)
                  )
          'face 'focus-focused
          )
         )
        ))

(dolist (x '((ns-transparent-titlebar . unbound)
             (ns-appearance . unbound)))
  (add-to-list 'frameset-filter-alist x))

(menu-bar-mode 1)
(tool-bar-mode -1)

;; (defun my/disable-scroll-bars (frame)
;;   (interactive)
;;   (modify-frame-parameters frame
;;                            '((vertical-scroll-bars . nil)
;;                              (horizontal-scroll-bars . nil))))
;; (add-hook 'after-make-frame-functions 'my/disable-scroll-bars)

(horizontal-scroll-bar-mode 1)
(scroll-bar-mode 1)


;; margins

;; fringe
(fringe-mode '(15 . 10))


(add-to-list 'brushup-styles
             '(progn
                (set-face-attribute 'fringe nil
                                    :background brushup-bg-1_0
                                    )
                )
             )

;;(progn
;;(define-fringe-bitmap 'tilde [0 0 0 113 219 142 0 0] 8 8 'center)
;;(setcdr (assq 'empty-line fringe-indicator-alist) 'tilde))

(fset 'yes-or-no-p 'y-or-n-p)



(setq blink-cursor-mode nil)

