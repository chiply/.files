;; TODO - post my original problem in the emacs reddit


;; pre build hydras?... also would we want these to be verbose?

;; config.. will push maps to a list, for each element in the list, we
;; will run this eval to create the hydra. DONE

;; nesting? DONE

;; how to include docuemntation

;; calculate columns DONE
;;; TODO column overflow, what to do...

;; prefix key to show docs instead?

;; which-key like behavor

;;(require 'evil)
;;(require 'which-key)
;;;; evil-window

;; does which key undo still work?

;; example for how this could replace declaring a hydra
;; two usecases -- turning an existing keymap into a hydra
;; declaring an entirely new keymap, binding keys, and then making
;; iinto a hades


;; easy way to get exiting hydras?  would emulate which keys behavior... but would probably lose which key features



(setq hades-registry '())
(setq hades-max-height 10)



(defun hades (map)
  (eval
   `(defhydra
      ;; name
      ,(intern (concat "hades-" map))
      ;; columns
      (:columns ,(+ 1 (/ (length
                          (which-key--get-keymap-bindings
                           (intern map)
                           nil nil nil
                           t ; prefix
                           t ; evil
                           ))
                         hades-max-height)))
      ;; heads
      ,@(mapcar (lambda (x)
                  (list (car x) (intern (cdr x)) (cdr x)))
                (which-key--get-keymap-bindings
                 (intern map)
                 nil nil nil
                 t ; prefix
                 t ; evil
                 ))
      ;; other useful keys (see defhydra+)
      ("q" nil "quit"))))


;; evil-window




(add-to-list 'hades-registry "evil-window-map")
(add-to-list 'hades-registry "hlt-map")


;; create all the hades
(-map
 (lambda (mapnm) (when (keymapp (intern mapnm)) (hades mapnm)))
 hades-registry)




