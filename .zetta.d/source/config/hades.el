;; TODO - post my original problem in the emacs reddit


;; pre build hydras?... also would we want these to be verbose?

;; more features:
;;;; fine grain control for hydra: color, exit for certain functions, messages, etc...

;;;; define higher level keybindings! what would a consistent way to do this be?  basically, invoke a 
;;;; ohhhh, could we define the hydra on the fly?  or would this interfere withe potential customizeability... I guess we can do both, fall back to defining it on the fly.
;; basically though, there would be a key like s-. would allow the end user to pass a prefix

;; nesting? DONE
;; finer nesting: actualy traversal through the tpl of hydras

;; calculate columns DONE
;;; TODO column overflow, what to do...

;; prefix key to show docs instead?

(setq hades-registry '())
(setq hades-max-height 20)



(defun hades (tpl)
  (eval
   `(defhydra
      ;; name
      ,(intern (concat "hades-" (car tpl)))
      ;; columns
      (:columns ,(+ 1 (/ (length (which-key--get-keymap-bindings (cadr tpl) nil nil nil t t))
                         hades-max-height)))
      ;; heads
      ,@(mapcar
         (lambda (x) (list (car x) (intern (cdr x)) (cdr x)))
         (which-key--get-keymap-bindings (cadr tpl) nil nil nil t t) 
         )
      ;; other useful keys (see defhydra+)
      ("q" nil "quit"))))


;; each config can use one of these lines to create a convenient hydra
(add-to-list 'hades-registry `("evil-window-map" ,evil-window-map))
(add-to-list 'hades-registry `("hlt-map" ,hlt-map))
(add-to-list 'hades-registry `("lsp-mode-map" ,lsp-mode-map))


;; create all the hades
(defun hades-create-hydras ()
  (-map
   (lambda (tpl) (hades tpl))
   hades-registry)
  )


;; create the hydras
(hades-create-hydras)




