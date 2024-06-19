(use-package orderless
  :init
  ;; style dispatchers
  (defun flex-if-twiddle (pattern _index _total)
    (when (string-prefix-p "~" pattern)
      `(orderless-flex . ,(substring pattern 1))))


  (defun my/orderless-dispatcher-initialism (pattern index _total)
    (when (string-prefix-p "`" pattern)
      `(orderless-initialism . ,(substring pattern 1))
      )
    )

  (defun without-if-bang (pattern _index _total)
    (cond
     ((equal "!" pattern)
      '(orderless-literal . ""))
     ((string-prefix-p "!" pattern)
      `(orderless-without-literal . ,(substring pattern 1)))))

  ;; orderless config 
  (setq orderless-matching-styles '(orderless-regexp)
        orderless-style-dispatchers '(my/orderless-dispatcher-initialism
                                      flex-if-twiddle
                                      without-if-bang)
        completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion))))
  ;; to plase corfu
  (add-to-list 'completion-styles-alist
               '(tab completion-basic-try-completion ignore
                     "Completion style which provides TAB completion only."))
  (setq completion-styles '(tab orderless basic))

  )


;;Persist history over Emacs restarts. Vertico sorts by history position.
(use-package savehist
  :init
  (savehist-mode)
  (setq savehist-file (expand-file-name ".data/savehist/history" user-emacs-directory))
  ;; doesn't work as it's not printable(?)
  ;;(add-to-list 'savehist-additional-variables 'bookmark-alist)
  )


