(use-package compile
  :straight (:type built-in)
  :general
  (
   :keymaps '(override)
   "s-r" 'recompile
   )
  )


;;(defun compilation--silly-buffer-name (name-of-mode)
  ;;(let (
        ;;(foo "bar")
        ;;(mod (symbol-name major-mode))
        ;;)
    ;;mod)
  ;;)
;;(compilation--silly-buffer-name "foobar")
;;(setq compilation-buffer-name-function 'compilation--silly-buffer-name)
