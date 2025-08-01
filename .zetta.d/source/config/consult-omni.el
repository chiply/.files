(use-package browser-hist
  :demand t
  :config
  (setq browser-hist-default-browser 'chrome))

(use-package consult-omni
  :straight (consult-omni
             :type git
             :host github
             :repo "armindarvish/consult-omni"
             :branch "main"
             :files (:defaults "sources/*.el"))
  :demand t
  :after (consult browser-hist embark) 

  :config
  ;; in regular consult-gh-search-repos
  (setq consult-omni-default-count 5)

  ;; load sources core code
  (require 'consult-omni-sources)
  (require 'consult-omni-embark)

  (which-key-add-keymap-based-replacements consult-omni-embark-general-actions-map
    "i" "consult-omni-embark-scholar-actions-map"
    "o" "omni actions"
    "w" "copy")


  ;; more sensible, prevents needless queries while typing
  (setq consult-omni-dynamic-input-debounce 0.5)


  ;; individual sources
  (require 'consult-omni-brave-autosuggest)
  (require 'consult-omni-brave)
  (require 'consult-omni-google)
  (require 'consult-omni-wikipedia)
  (require 'consult-omni-brave)
  (require 'consult-omni-pubmed)
  (require 'consult-omni-buffer)
  (require 'consult-omni-gptel)
  (use-package consult-omni-gh
    :ensure nil
    :demand t
    :config
    (consult-omni-define-source "GitHub"
                                :narrow-char ?h
                                :type 'async
                                :require-match nil
                                :category 'consult-gh-repos
                                :face 'consult-omni-engine-title-face
                                :request #'consult-gh--search-repos-builder
                                :on-preview #'consult-omni--gh-preview
                                :on-return #'identity
                                :on-callback #'consult-omni--gh-callback
                                :preview-key consult-omni-preview-key
                                :search-hist 'consult-omni--search-history
                                :select-hist 'consult-omni--selection-history
                                :group #'consult-omni--group-function
                                :sort t
                                :interactive consult-omni-intereactive-commands-type
                                :transform #'consult-omni--gh-transform
                                :enabled (lambda () (and (executable-find "gh")
                                                         (fboundp 'consult-gh-search-repos)))
                                :annotate nil)

    )
  ;; TODO can't pass args to gh search command in consult omni , can
  ;; with consult-gh
  (require 'consult-omni-man)
  (require 'consult-omni-stackoverflow)
  (require 'consult-omni-youtube)
  
  (require 'consult-omni-browser-history)
  ;;(use-package consult-omni-browser-history
  ;;:ensure nil
  ;;:after browser-hist
  ;;:demand t
  ;;)
  (require 'consult-omni-apps)
  (require 'consult-omni-doi)
  (require 'consult-omni-grep)
  (require 'consult-omni-find)
  (require 'consult-omni-fd)
  (require 'consult-omni-git-grep)
  (require 'consult-omni-ripgrep)
  ;; NOTE ripgrep all allows for search through PDF and archive files,
  ;; extremely powerful
  (require 'consult-omni-ripgrep-all)
  (use-package dictionary
    :ensure nil
    :config
    (setq consult-omni-dict-server "dict.org"))

  (require 'consult-omni-dict) ;; TODO not working

  ;; TODO custom source for arxiv (anything else from lookup)
  (consult-omni-sources-load-modules)


  ;; pubmed not working
  (setq consult-omni-multi-sources
        '("Brave" "Google" "Wikipedia" "Buffer" "gptel" "PubMed"
          "GitHub" "man" "Browser History" "StackOverflow" "YouTube"))

  ;; TODO fix stack overflow
  ;; TODO fix youtube
  ;; TODO add numi

  (setq consult-omni-finder-sources '("ripgrep-all" "Buffer" "fd"))

  (setq consult-omni-scholar-sources '("Wikipedia" "gptel" "PubMed"))


  (defun consult-omni-multi* (&optional initial prompt sources no-callback &rest args)
    (interactive "P")
    (let ((sources (or sources consult-omni-multi-sources)))
      (consult-omni-multi initial prompt sources no-callback args)))
  (consult-customize consult-omni-multi* :preview-key "C-=")

  (defun consult-omni-multi-suggesting* (&optional initial prompt sources no-callback &rest args)
    (interactive "P")
    (let ((initial (consult-omni-brave-autosuggest))
          (sources (or sources consult-omni-multi-sources)))
      (consult-omni-multi initial prompt sources no-callback args)))
  (consult-customize consult-omni-multi-suggesting* :preview-key "C-=")

  (defun consult-omni-scholar (&optional initial prompt sources no-callback &rest args)
    (interactive "P")
    (let ((sources (or sources consult-omni-scholar-sources)))
      (consult-omni-multi initial prompt sources no-callback args)))

  (defun consult-omni-finder (&optional initial prompt sources no-callback &rest args)
    (interactive "P")
    (let ((sources (or sources consult-omni-finder-sources)))
      (consult-omni-multi initial prompt sources no-callback args)))

  ;; NEXT history per endpoint -- eg different history for finder and scholar

  ;; TODO no embark actions working in collect or export buffer

  ;; TODO replace bespoke libraries (helm, wikipedia, pubmed.
  ;; 'lookup' is a great place to start looking at what can be
  ;; migrated)

  ;; actions to work in export/collect

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

  ;; prevents white background that doesn't show up well in flat mode
  (set-face-attribute 'consult-omni-default-face nil :inherit nil)

  :general
  (:keymaps 'override "S-s-SPC" #'consult-omni-multi*)
  )
