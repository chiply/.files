(use-package highlight-indent-guides

  ;; a surprisingl useful package

  ;; obvious use case: useful for orienting in json documents.  Same for
  ;; yaml, but is even more critical in yaml as whitespace determines
  ;; meaning, unlike json which can be minified without losing meaning

  ;; less obvious, but more useful features:

  ;; nice visual guides for programming languages where whitespace
  ;; really matters, like python.  For example, nice visual guide of
  ;; depth, function span.  Offers liter alternative to something like
  ;; focus mode for functions which uses basic indentation.

  ;; useful indicator of org src blocks, can turn off the annoying
  ;; background highlighting

  ;; trying it basically everywhere for now

  ;; interestinigly doesn't work super well in dired

  :config
  ;; no bitmap, changes widths
  (setq highlight-indent-guides-method 'character)
  (setq highlight-indent-guides-auto-enabled t)
  ;; useful because it lets trace up the stack to orient where you are
  ;; in the tree
  (setq highlight-indent-guides-responsive 'stack)
  ;; lower number increases the contrast.  5 seems to be a good
  ;; compromise between subtlety and clarity
  (setq highlight-indent-guides-auto-character-face-perc 5)

  (highlight-indent-guides-auto-set-faces)

  :hook (
         (
          json-mode
          ;;yaml-mode
          org-mode
          ;; python-ts-mode
          emacs-lisp-mode
          ) .
         highlight-indent-guides-mode
         )
  )
