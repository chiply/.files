(use-package consult-omni
  :straight (consult-omni
             :type git
             :host github
             :repo "armindarvish/consult-omni"
             :branch "main"
             :files (:defaults "sources/*.el"))
  :after consult

  :config

  ;; load sources core code
  (require 'consult-omni-sources)
  (require 'consult-omni-embark)

  ;; individual sources
  (require 'consult-omni-brave-autosuggest)
  (require 'consult-omni-brave)
  (require 'consult-omni-google)
  (require 'consult-omni-wikipedia)
  (require 'consult-omni-brave)
  (require 'consult-omni-pubmed)
  (require 'consult-omni-buffer)
  (require 'consult-omni-gptel)
  (require 'consult-omni-gh)
  (require 'consult-omni-man)
  (require 'consult-omni-stackoverflow)
  (require 'consult-omni-youtube)

  ;; TODO custom source for arxiv (anything else from lookup)
  (consult-omni-sources-load-modules)

  ;; pubmed not working
  (setq consult-omni-multi-sources '("Brave" "Google" "Wikipedia"
                                     "Buffer" "gptel" "PubMed"
                                     "GitHub" "man"
                                     ;; "StackOverflow"
                                     ;; "YouTube"
                                     ))

  (setq consult-omni-scholar-sources '("Wikipedia" "gptel" "PubMed"))

  (defun consult-omni-multi* (&optional initial prompt sources no-callback &rest args)
    (interactive "P")
    ;; NOTE enables the narrowing to prevent wastefulness in
    ;; consult-omni-multi-sources
    (let ((consult-async-split-style 'comma)
          (sources (or sources consult-omni-multi-sources)))
      (consult-omni-multi initial prompt sources no-callback args)))

  (defun consult-omni-scholar (&optional initial prompt sources no-callback &rest args)
    (interactive "P")
    (let ((sources (or sources consult-omni-scholar-sources)))
      (consult-omni-multi initial prompt sources no-callback args)))

  (defun consult-omni-scholar (&optional initial prompt sources no-callback &rest args)
    (interactive "P")
    (let ((sources (or sources consult-omni-scholar-sources)))
      (consult-omni-multi initial prompt sources no-callback args)))

  ;; TODO replace bespoke libraries (helm, wikipedia, pubmed.
  ;; 'lookup' is a great place to start looking at what can be
  ;; migrated)

  ;; TODO 1st source -- try create a multi for ripgrep where you
  ;; search relevant terms across project (helpful in cases where you
  ;; are making 1 change that will impact multiple projects)... or for
  ;; doing a full text search across all repos for something like a
  ;; reference, or when trying to find how, for example, something
  ;; from the SDK is used through GeneDx codebases

  ;; TODO 1 embark action for each kind of browse url -- eww, xwidget, EAF, external

  ;; TODO how would a password managment solution look like in this? 

  ;;; Set your shorthand favorite interactive command
  (setq consult-omni-default-interactive-command #'consult-omni-brave-autosuggest)

  :general
  (:keymaps 'override "S-s-SPC" #'consult-omni-multi*)
  )
