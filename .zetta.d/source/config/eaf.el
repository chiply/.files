;; may need to eaf-install-and-update
(use-package eaf
  :straight (eaf
             :type git
             :host github
             :repo "emacs-eaf/emacs-application-framework"           
             :files ("*.el" "*.py" "core" "app" "*.json")
             ;; Straight won't try to search for these packages when we
             ;; make further use-package invocations for them
             :includes (eaf-pdf-viewer eaf-browser) 
             :pre-build ("python3" "install-eaf.py" "--install" "pdf-viewer" "browser" "--ignore-sys-deps")
             )
  ;; Evil mode doesn't work well with eaf keybindings.
  :init (evil-set-initial-state 'eaf-mode 'emacs)) 


;; note: started up with super weird display settings
(use-package eaf-browser
  :custom
  (eaf-browser-continue-where-left-off t)
  (eaf-browser-enable-adblocker t))

;; note pymupdf is a dependency!!!
;; don't get a nice occur buffer
;; still need to figure out annotations
;; what happens when visiting pdf in the browser
(use-package eaf-pdf-viewer)
