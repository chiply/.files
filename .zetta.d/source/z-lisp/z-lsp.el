;;;;; z-lsp.el --- Extensions for lsp -*- lexical-binding: t -*-
;;
;;
;;;;; Code:
;;(require 'lsp)
;;(require 'lsp-ui)
;;(require 'lsp-treemacs)
;;
;;;; for performance
;;(setq gc-cons-threshold 100000000)
;;(setq read-process-output-max (* 1024 1024))
;;
;;
;;;; LEFT OFF TODO implement my own find definitioin function!!! should also pop up in side windows, but ensure in a different slot!!!!
;;;; this gives best of both worlds :)  Although technicallyy, the code buffer would also contain the docs...  CAn tie in the same way as intellisense... just instead of help, we implement goto (maybe a different flag?)
;;;; RReplace display functions with my special function
;;;; nows probably a good time for magneto 
;;
;;(setq
 ;;lsp-enable-completion-at-point t
 ;;lsp-completion-provider :none
 ;;lsp-idle-delay nil
 ;;lsp-tooltip-idle-delay nil
 ;;lsp-headerline-breadcrumb-enable nil
 ;;lsp-enable-snippet nil
 ;;lsp-enable-indentation nil
 ;;lsp-enable-xref nil
 ;;lsp-eldoc-render-all nil
 ;;lsp-eldoc-enable-hover nil
 ;;lsp-diagnostics-provider 'flycheck
 ;;lsp-semantic-highlighting nil
 ;;lsp-signature-render-documentation nil
 ;;lsp-signature-auto-activate nil
 ;;lsp-enable-symbol-highlighting nil
 ;;lsp-modeline-code-actions-enable nil
;;
 ;;lsp-session-file (expand-file-name ".data/lsp/.lsp-session-v1" user-emacs-directory)
;;
 ;;)
;;
;;
;;
;;
;;;; see issue: https://github.com/tigersoldier/company-lsp/issues/145
;;(defun lsp--sort-completions (completions)
  ;;(lsp-completion--sort-completions completions))
;;
;;(defun lsp--annotate (item)
  ;;(lsp-completion--annotate item))
;;
;;(defun lsp--resolve-completion (item)
  ;;(lsp-completion--resolve item))
;;
;;;;;###autoload
;;(defun lsp-describe-thing-at-point-1 ()
  ;;"Display the type signature and documentation of the thing at
;;point."
  ;;(interactive)
  ;;(let ((thing (z-contiguous-chars-at-point))
        ;;(contents (-some->> (lsp--text-document-position-params)
                    ;;(lsp--make-request "textDocument/hover")
                    ;;(lsp--send-request)
                    ;;(lsp:hover-contents))))
    ;;(if (and contents (not (equal contents "")))
        ;;(let* ((lsp-help-buf-name (concat "*L: " thing "*"))
               ;;(buf (get-buffer-create lsp-help-buf-name)))
          ;;(with-current-buffer buf
            ;;(text-mode)
            ;;(erase-buffer)
            ;;(insert (string-trim-right (lsp--render-on-hover-content contents t)))
            ;;(beginning-of-buffer))
          ;;(display-buffer buf)
          ;;)
      ;;(lsp--info "No content at point."))))
;;
;;;;;###autoload
;;(defun lsp-find-definition-1 ()
  ;;"Display the type signature and documentation of the thing at
;;point."
  ;;(interactive)
  ;;(lsp-find-definition)
  ;;(let ((buf (current-buffer)))
    ;;(bury-buffer)
    ;;(display-buffer-in-side-window
     ;;buf
     ;;'(
       ;;(side . right)
       ;;(window-width . 0.30)
       ;;(window-parameters . ((no-delete-other-windows . 1)))
       ;;))
    ;;)
  ;;)
;;
;;;;;###autoload
;;(defun evil-goto-definition-1 ()
  ;;"Display the type signature and documentation of the thing at
;;point."
  ;;(interactive)
  ;;(evil-goto-definition)
  ;;(let ((buf (current-buffer)))
    ;;(bury-buffer)
    ;;(display-buffer-in-side-window
     ;;buf
     ;;'(
       ;;(side . right)
       ;;(slot . 1)
       ;;(window-width . 0.30)
       ;;(window-parameters . ((no-delete-other-windows . 1)))
       ;;))
    ;;)
  ;;)
;;
;;;; python
;;(setq lsp-language-id-configuration '())
;;(add-to-list 'lsp-language-id-configuration '(python-mode . "python"))
;;;; yaml
;;(add-to-list 'lsp-language-id-configuration '(yaml-mode . "yaml"))
;;;; json
;;(add-to-list 'lsp-language-id-configuration '(json-mode . "json"))
;;(add-to-list 'lsp-language-id-configuration '(jsonian-mode . "json"))
;;;; bash
;;(add-to-list 'lsp-language-id-configuration '(sh-mode . "bash"))
;;
;;(lsp-register-client
 ;;(make-lsp-client :new-connection (lsp-stdio-connection "pylsp")
                  ;;:activation-fn (lsp-activate-on "python")
                  ;;:server-id 'pylsp))
;;(lsp-register-client
 ;;(make-lsp-client :new-connection (lsp-stdio-connection "yaml-language-server")
                  ;;:activation-fn (lsp-activate-on "yaml")
                  ;;:server-id 'yaml-language-server))
;;(lsp-register-client
 ;;(make-lsp-client :new-connection (lsp-stdio-connection "vscode-json-languageserver --stdio")
                  ;;:activation-fn (lsp-activate-on "json")
                  ;;:server-id 'vscode-json-languageserver
                  ;;:priority 5))
;;
;;
;;
;;;; this needs to go to private
;;;; also, use expand-file-name
;;(setq
 ;;lsp-yaml-schemas
 ;;'(
   ;;;; DEMO
   ;;(/Users/redacted/projects/spikes/jsonschema_for_configuration/schemas/fhir.schema.json
    ;;.
    ;;["patient_*.yml"]
    ;;)
   ;;;; other
   ;;;; ...
  ;; 
   ;;)
 ;;)
;;
;;(setq
 ;;lsp-json-schemas
 ;;'(
   ;;;; DEMO
   ;;(/Users/redacted/projects/spikes/jsonschema_for_configuration/schemas/fhir.schema.json
    ;;.
    ;;["patient_*.json"]
    ;;)
   ;;;; other
   ;;;; ...
   ;;)
 ;;)
;;
;;(setq lsp-headerline-breadcrumb-icons-enable nil)
;;(setq lsp-headerline-breadcrumb-enable-diagnostics t)
;;(setq lsp-headerline-breadcrumb-segments '(symbols))
;;
;;;; need to turn on and off for the breadcrumb to be used elsewhere
;;(lsp-headerline-breadcrumb-mode 1)
;;(lsp-headerline-breadcrumb-mode -1)
;;
;;
;;(z-side "^\\*L: *" 'right)
;;
;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Jumping to docs from point
;;;;;###autoload
;;(defun z-jump-to-doc ()
  ;;(interactive)
  ;;(condition-case nil
      ;;(helpful-at-point)
    ;;(error (lsp-describe-thing-at-point-1)))
  ;;)
;;
;;
;;
;;(defun z-side-window-p (win)
  ;;(window-parameter win 'window-slot)
  ;;)
;;
;;(defun z-aw-window-list-nonside ()
  ;;"Counts non side windows"
  ;;(-filter (lambda (x) (not (z-side-window-p x))) (aw-window-list))
  ;;)
;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Jumping to definition from point
;;;;;###autoload
;;(defun z-jump-to-def ()
  ;;(interactive)
  ;;(let ((buf (current-buffer)))
    ;;(aw-select "select a window: "
               ;;(lambda (window)
                 ;;(aw-switch-to-window window)
                 ;;(switch-to-buffer buf)
                 ;;(evil-goto-definition)
                 ;;))
    ;;)
  ;;)
;;
;;;;;###autoload
;;(defun z-jump-to-def-vert ()
  ;;(interactive)
  ;;(let ((buf (current-buffer)))
    ;;(if (> (length (z-aw-window-list-nonside)) 1)
        ;;(aw-select "select a window: "
                   ;;(lambda (window)
                     ;;(aw-switch-to-window window)
                     ;;(split-window-below)
                     ;;(windmove-down)
                     ;;(switch-to-buffer buf)
                     ;;(evil-goto-definition)
                     ;;)
                   ;;)
      ;;(progn
        ;;(split-window-below)
        ;;(windmove-down)
        ;;(switch-to-buffer buf)
        ;;(evil-goto-definition)
        ;;)
      ;;)
    ;;)
  ;;)
;;
;;;;;###autoload
;;(defun z-jump-to-def-vert-1 ()
  ;;(interactive)
  ;;(let ((buf (current-buffer)))
    ;;(if (> (length (z-aw-window-list-nonside)) 1)
        ;;(aw-select "select a window: "
                   ;;(lambda (window)
                     ;;(aw-switch-to-window window)
                     ;;(split-window-below)
                     ;;(switch-to-buffer buf)
                     ;;(evil-goto-definition)
                     ;;))
      ;;(progn
        ;;(split-window-below)
        ;;(switch-to-buffer buf)
        ;;(evil-goto-definition)
        ;;)
      ;;)
    ;;)
  ;;)
;;
;;
;;
;;;;;###autoload
;;(defun z-jump-to-def-hor ()
  ;;(interactive)
  ;;(let ((buf (current-buffer)))
    ;;(if (> (length (z-aw-window-list-nonside)) 1)
        ;;(aw-select "select a window: "
                   ;;(lambda (window)
                     ;;(aw-switch-to-window window)
                     ;;(split-window-right)
                     ;;(windmove-right)
                     ;;(switch-to-buffer buf)
                     ;;(evil-goto-definition)
                     ;;))
      ;;(progn
        ;;(split-window-right)
        ;;(windmove-right)
        ;;(switch-to-buffer buf)
        ;;(evil-goto-definition)
        ;;)
      ;;)
    ;;) 
  ;;)
;;
;;;;;###autoload
;;(defun z-jump-to-def-hor-1 ()
  ;;(interactive)
  ;;(let ((buf (current-buffer)))
    ;;(if (> (length (z-aw-window-list-nonside)) 1)
        ;;(aw-select "select a window: "
                   ;;(lambda (window)
                     ;;(aw-switch-to-window window)
                     ;;(split-window-right)
                     ;;(switch-to-buffer buf)
                     ;;(evil-goto-definition)
                     ;;))
      ;;(progn
        ;;(split-window-right)
        ;;(switch-to-buffer buf)
        ;;(evil-goto-definition)
        ;;)
      ;;)
    ;;) 
  ;;)
;;
;;
;;;;;###autoload
;;(defun z-jump-to-def-side ()
  ;;(interactive)
  ;;(let ((buf (current-buffer)))
    ;;(select-window
     ;;(display-buffer-in-side-window buf '(
                                          ;;(side . right)
                                          ;;(side . right)
                                          ;;(slot . 0)
                                          ;;(window-width . 0.30)
                                          ;;(window-parameters . ((no-delete-other-windows . 1)))
                                          ;;)))
    ;;(evil-goto-definition)
    ;;))
;;
;;
;;
;;(general-define-key
 ;;:keymaps '(lisp-mode-map
            ;;lisp-interaction-mode-map
            ;;emacs-lisp-mode-map
            ;;lisp-data-mode-map
            ;;python-mode-map)
 ;;:states '(normal) 
 ;;"gdd" 'evil-goto-definition
 ;;"gdo" 'z-jump-to-def
 ;;"gdh" 'z-jump-to-def-hor
 ;;"gdH" 'z-jump-to-def-hor-1
 ;;"gdv" 'z-jump-to-def-vert
 ;;"gdV" 'z-jump-to-def-vert-1
 ;;;; 
 ;;"gds" 'z-jump-to-def-side
 ;;"gh" 'z-jump-to-doc
 ;;)
;;
;;
;;(setq lsp-ui-sideline-enable nil)
;;
;;(lsp-treemacs-sync-mode 1)
;;(setq lsp-treemacs-theme "all-the-icons")
;;
;;
;;
;;
;;(provide 'z-lsp)
;;;;; z-lsp.el ends here
