(use-package reader
  :ensure '(reader :type git :host codeberg :repo "divyaranjan/emacs-reader"
                   :files ("*.el" "render-core.so")
                   :pre-build ("make" "all")))
