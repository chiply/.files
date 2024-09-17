(use-package hydra
  :demand t

  :config

  (setq hydra-registry '())
  (defun z-hydra-init (name)
    "Function used to instantiate a hydra following a special
template.  This template handles setting up a generic docstring, C-g
for quitting, and s-x for hide-showing the hint."
    ;; define the hydra
    (eval
     `(defhydra ,(intern name) ()
        (format "%s: " name) ;; docstring
        ("C-g" (hydra-set-property (intern ,name) :verbosity 0)
         "exit" :exit t)
        ("s-x"
         (cond
          ((eq 0 (hydra-get-property (intern ,name) :verbosity))
           (hydra-set-property (intern ,name) :verbosity 1))
          ((eq 1 (hydra-get-property (intern ,name) :verbosity))
           (hydra-set-property (intern ,name) :verbosity 0))))))
    ;; set the verbosity to 0 (eg don't show the docstrinig)
    (eval `(hydra-set-property (intern ,name) :verbosity 0))
    ;; add the name to the hydra registry (useful for introspection)
    (push name hydra-registry))

  ;; redefining macro from hydra.el
  (defmacro defhydra+ (name body &optional docstring &rest heads)
    "Redefine an existing hydra by adding new heads.
Arguments are same as of `defhydra'."
    (unless (fboundp (intern (concat (symbol-name name) "/body")))
      (z-hydra-init (symbol-name name)))
    (declare (indent defun) (doc-string 3))
    (unless (stringp docstring)
      (setq heads (cons docstring heads))
      (setq docstring nil))
    `(defhydra ,name ,(or body (hydra--prop name "/params"))
       ,(or docstring (hydra--prop name "/docstring"))
       ,@(cl-delete-duplicates
          (append (hydra--prop name "/heads") heads)
          :key #'car
          :test #'equal)))
  
  :brushup
  (add-to-list 'brushup-styles
               '(progn
                  (set-face-attribute 'hydra-face-red nil
                                      :foreground brushup-fg
                                      :underline t)
                  (set-face-attribute 'hydra-face-blue nil
                                      :foreground brushup-fg-3)))
  

  :general
  (
   :keymaps 'launch-map
   "w" 'hydra-window/body
   "p" 'hydra-projectile/body
   )


  ;;(
  ;;:keymaps '(evil-insert-state-map)
  ;;(general-chord ",w") 'hydra-window/body
  ;;(general-chord ",p") 'hydra-projectile/body
  ;;)
  ;;(
  ;;:keymaps 'override
  ;;:states '(normal visual)
  ;;:prefix ","
  ;;"w" 'hydra-window/body
  ;;"p" 'hydra-projectile/body
  ;;)


  :hook (use-package--hydra--post-config . z-brushup)
  )



(defalias 'use-package-handler/:hydra 'use-package-handle-forms)
(defalias 'use-package-normalize/:hydra 'use-package-normalize-forms)
(add-to-list 'use-package-keywords :hydra t)

(provide 'bootstrap-hydra)




