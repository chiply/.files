(use-package devdocs
  :config
  (require 'cl-lib)
  (setq z-devdocs-installed-langs (mapcar
                                   (lambda (it) (alist-get 'slug it))
                                   (devdocs--installed-docs)))

  (setq
   z-devdocs-langs-to-install
   '("javascript" "python~3.12" "svelte" "css" "vite" "typescript" "c"
     "r" "i3" "jq" "git" "man" "npm" "zsh" "bash" "d3~7" "html" "htmx"
     "http" "node" "rust" "yarn" "elisp" "cmake" "latex" "nginx"
     "react" "redis" "docker" "duckdb" "jquery" "sqlite" "fastapi"
     "homebrew" "markdown" "pandas~2" "jinja~3.1" "terraform"
     "tensorflow" "postgresql~18"))

  (setq z-devdocs-uninstalled-langs
        (cl-set-difference z-devdocs-langs-to-install
                           z-devdocs-installed-langs :test 'string=))

  ;; install all missing devdocs
  ;; TODO -- might be running into API errors here
  ;;(dolist (lang z-devdocs-uninstalled-langs)
    ;;(devdocs-install lang))

  )






