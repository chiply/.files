;; may need to eaf-install-and-update
(use-package eaf
  :straight (eaf
             :type git
             :host github
             :repo "emacs-eaf/emacs-application-framework"           
             :files ("*.el" "*.py" "core" "app" "*.json")
             ;; Straight won't try to search for these packages when we
             ;; make further use-package invocations for them
             :includes (eaf-pdf-viewer
                        eaf-browser
                        eaf-image-viewer
                        eaf-terminal
                        eaf-org-previewer
                        eaf-markdown-previewer
                        )
             :pre-build ("python3"
                         "install-eaf.py"
                         "--install"
                         "pdf-viewer"
                         "browser"
                         "image-viewer"
                         "terminal"
                         "org-previewer"
                         "markdown-previewer"

                         "--ignore-sys-deps")
             )
  ;; Evil mode doesn't work well with eaf keybindings.
  :init (evil-set-initial-state 'eaf-mode 'emacs)

  :config

  (defun z-eaf-switch-to-eww ()
    (interactive)
    (eww-browse-url (eaf-get-path-or-url))
    )



  ) 


;; note: started up with super weird display settings
(use-package eaf-browser
  :custom
  (eaf-browser-continue-where-left-off t)
  (eaf-browser-enable-adblocker t)
  :config
  (eaf-bind-key z-eaf-switch-to-eww "C-&" eaf-browser-keybinding)



  )

;; note pymupdf is a dependency!!!
;; don't get a nice occur buffer
;; still need to figure out annotations
;; what happens when visiting pdf in the browser
(use-package eaf-pdf-viewer)

;;
(use-package eaf-image-viewer)
(use-package eaf-terminal)

(use-package eaf-markdown-previewer)
(use-package eaf-org-previewer)
