(window-divider-mode -1)
(setq window-divider-default-places t)
(setq window-divider-default-bottom-width 5
      window-divider-default-right-width 5)
(window-divider-mode 1)

(add-to-list 'brushup-styles
             '(progn
                (set-face-attribute 'window-divider nil
                                    :foreground brushup-bg-2
                                    )
                )
             )

;; todo: will be way more complicated than this
;;(defun z-select-previous-window ()
  ;;(interactive)
  ;;(select-window (previous-window))
  ;;)

(defhydra+ hydra-window ()
  ;; mneuumonic is that the o is a circle, so gets rid of or relaxes
  ;; tthat visual wireframe
  ("o" (lambda () (interactive) (call-interactively 'window-divider-mode)))
  )

(add-to-list 'window-persistent-parameters '(window-side . writable))
(add-to-list 'window-persistent-parameters '(window-slot . writable))
(add-to-list 'window-persistent-parameters '(clone-of . writable))
(add-to-list 'window-persistent-parameters '(no-delete-other-windows . writable))
(add-to-list 'window-persistent-parameters '(split-window . writable))
(add-to-list 'window-persistent-parameters '(min-margins . writable))
(add-to-list 'window-persistent-parameters '(quit-restore . writable))


(defhydra+ hydra-window ()
  ("D" delete-window)
  ("C-S-d" delete-other-windows)
  ("C-S-S" window-toggle-side-windows)
  ("C-S-b b" (lambda ()
               (interactive)
               (if (get-scroll-bar-mode)
                   (set-scroll-bar-mode nil)
                 (set-scroll-bar-mode 'left))
               )
   )
  ("C-S-b h" horizontal-scroll-bar-mode)
  ("mm" balance-windows)
  ("mk" minimize-window)
  ("mj" maximize-window)
  ("C-v" visual-line-mode)
  ("C-t" toggle-truncate-lines)
  ("C-t" toggle-truncate-lines)
  ("C-w" toggle-word-wrap)
  )

(defhydra+ hydra-window ()
  ("f" z-projectile-find-file)
  ("F" find-file)
  ("x" execute-extended-command)
  )

(defhydra+ hydra-window ()
  ("r" hydra-resize/body :exit t)
  )

(defhydra+ hydra-resize ()
  ("w" hydra-window/body :exit t)
  ("h" (lambda () (interactive) (shrink-window-horizontally 1)) "1" :column "Shrink |")
  ("C-h" (lambda () (interactive) (shrink-window-horizontally 2)) "2")
  ("C-S-h" (lambda () (interactive) (shrink-window-horizontally 4)) "4")
  ("l" (lambda () (interactive) (enlarge-window-horizontally 1)) "1" :column "Enlarge |")
  ("C-l" (lambda () (interactive) (enlarge-window-horizontally 2)) "2")
  ("C-S-l" (lambda () (interactive) (enlarge-window-horizontally 4)) "4")
  ("j" (lambda () (interactive) (shrink-window 1)) "1" :column "Shrink --")
  ("C-j" (lambda () (interactive) (shrink-window 2)) "2")
  ("C-S-j" (lambda () (interactive) (shrink-window 4)) "4")
  ("k" (lambda () (interactive) (enlarge-window 1)) "1" :column "Enlarge --")
  ("C-k" (lambda () (interactive) (enlarge-window 2)) "2")
  ("C-S-k" (lambda () (interactive) (enlarge-window 4)) "4")
  )

(defhydra+ hydra-run ()
  ("r" window-toggle-side-windows "Toggle Side Windows")
  )


(defun z-async-blowup ()
  (interactive)
  (when (or (eq (window-parameter (selected-window) 'window-side) 'top)
            (eq (window-parameter (selected-window) 'window-side) 'bottom))
    (if (< (window-total-height) 25)
        (enlarge-window 30)
      (shrink-window 30)))
  (when (eq (window-parameter (selected-window) 'window-side) 'left)
    (if (< (window-total-width) 30)
        (enlarge-window 30 t)
      (shrink-window 30 t)))
  (when (eq (window-parameter (selected-window) 'window-side) 'right)
    (if (< (window-total-width) 90)
        (enlarge-window 30 t)
      (shrink-window 30 t)))
  (unless (window-parameter (selected-window) 'window-side)
    (message "This is not a side window"))
  )

(general-define-key
 :states '(normal insert visual)
 :keymaps '(override treemacs-mode-map)
 "C-p" 'z-async-blowup)



(make-local-variable 'z-zen-disable)

;; (defun z-set-window-margin-zen ()
;;   (unless (and (boundp 'z-zen-disable) z-zen-disable)
;;     (when
;;         (and
;;          (> (window-total-width) 160)
;;          (or (not (window-parameter (selected-window) 'window-slot)) (string= major-mode "org-mode"))
;;          (not (equal text-scale-mode-amount 2)) ;; it should be two when both the above cateogires are true
;;          )
;;       (text-scale-set 2)
;;       )
;;     (when
;;         (and
;;          (<= (window-total-width) 160)
;;          (>= (window-total-width) 50)
;;          (or (not (window-parameter (selected-window) 'window-slot)) (string= major-mode "org-mode"))
;;          (not (equal text-scale-mode-amount 0)) ;; it should be two when both the above cateogires are true
;;          )
;;       (text-scale-set 0)
;;       )
;;     (when
;;         (and
;;          (<= (window-total-width) 49)
;;          (>= (window-total-width) 0)
;;          (or (not (window-parameter (selected-window) 'window-slot)) (string= major-mode "org-mode"))
;;          (not (equal text-scale-mode-amount -2)) ;; it should be two when both the above cateogires are true
;;          )
;;       (text-scale-set -2)
;;       ) (when
;;       (and
;;        (or
;;         (string= (symbol-name (window-parameter (selected-window) 'window-side)) "right")
;;         (string= (symbol-name (window-parameter (selected-window) 'window-side)) "top")
;;         (string= (symbol-name (window-parameter (selected-window) 'window-side)) "left")
;;         (string= (symbol-name (window-parameter (selected-window) 'window-side)) "bottom")
;;         )
;;        (not (equal text-scale-mode-amount -2)) ;; it should be two when both the above cateogires are true
;;        )
;;       (text-scale-set -2)
;;       )
;;     )
;;   )

;; (defun z-zen-mode ()
;;   (add-hook 'window-configuration-change-hook 'z-set-window-margin-zen 0 'local)
;;   )
;; (add-hook 'prog-mode-hook 'z-zen-mode)
;; (add-hook 'window-configuration-change-hook 'z-zen-mode)

(general-define-key
 :keymaps 'override
 :states '(normal visual insert)
 "s-+" '(lambda () (interactive) (setq-local z-zen-disable t) (call-interactively 'text-scale-increase))
 "s-=" '(lambda () (interactive) (setq-local z-zen-disable t) (call-interactively 'text-scale-increase))

 "s--" '(lambda () (interactive) (setq-local z-zen-disable t) (call-interactively 'text-scale-decrease))

 "s-0" '(lambda () (interactive) (setq-local z-zen-disable t) (text-scale-adjust 0))
 "s-)" '(lambda () (interactive)
          ;; unlock
          (setq-local z-zen-disable nil)
          ;; and reset to (global) default size
          (text-scale-adjust 0))
 )






(setq z-tile-dimensions
      '((origin_x . 1)
        (origin_y . 1)
        (center_x . 960)
        (center_y . 600)
        (width . 239)
        (height . 84)
        (width_half . 119)
        (height_half . 36)))


(defun z-tile-split (arg)
  (interactive)
  (cond
   ((equal arg "left") (z-tile 'width_half 'height 'origin_x 'origin_y))
   ((equal arg "right") (z-tile 'width_half 'height 'center_x 'origin_y))
   ((equal arg "full") (z-tile 'width 'height 'origin_x 'origin_y))
   ((equal arg "top") (z-tile 'width 'height_half 'origin_x 'origin_y))
   ((equal arg "bot") (z-tile 'width 'height_half 'origin_x 'center_y))
   ((equal arg "topleft") (z-tile 'width_half 'height_half 'origin_x 'origin_y))
   ((equal arg "topright") (z-tile 'width_half 'height_half 'center_x 'origin_y))
   ((equal arg "botleft") (z-tile 'width_half 'height_half 'origin_x 'center_y))
   ((equal arg "botright") (z-tile 'width_half 'height_half 'center_x 'center_y))
   )
  )

(defun z-tile (sh sv ph pv)
  "This function tiles the frame on the screen"
  (when window-system (progn
                        (set-frame-size (selected-frame)
                                        (alist-get sh z-tile-dimensions)
                                        (alist-get sv z-tile-dimensions))
                        (set-frame-position (selected-frame)
                                            (alist-get ph z-tile-dimensions)
                                            (alist-get pv z-tile-dimensions))))
  )


(defhydra+ hydra-window ()
  ("M" hydra-tile/body :exit t)
  )
(defhydra+ hydra-tile ()
  ("w" hydra-window/body :exit t)
  ("m" toggle-frame-maximized "Maximize" :column "Full")
  ("i" (z-tile-split "top") "Top" :column "Half") 
  ("k" (z-tile-split "bot") "Bottom")
  ("h" (z-tile-split "left") "Left")
  (";" (z-tile-split "right") "Right")
  ("u" (z-tile-split "topleft") "Top Left" :column "Quarter")
  ("o" (z-tile-split "topright") "Top Right")
  ("j" (z-tile-split "botleft") "Bottom Left")
  ("l" (z-tile-split "botright") "Bottom Right")
  )

