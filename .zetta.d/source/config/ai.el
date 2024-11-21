(use-package copilot
  :straight (:host github :repo "zerolfx/copilot.el" :files ("dist" "*.el"))
  :demand t
  :config
  ;; modes
  (add-hook 'prog-mode-hook 'copilot-mode)
  (add-hook 'markdown-mode-hook 'copilot-mode)
  (add-hook 'org-mode-hook 'copilot-mode)
  (add-hook 'sql-mode-hook 'copilot-mode)
  (add-hook 'mermaid-mode-hook 'copilot-mode)
  (add-hook 'emacs-lisp-mode 'copilot-mode)
  (add-hook 'lisp-interaction-mode 'copilot-mode)

  ;; face
  (set-face-attribute 'copilot-overlay-face nil :foreground "purple" :inherit 'default)
  (setq copilot-indent-offset-warning-disable t)
  
  :general (:keymaps '(copilot-completion-map)
                     "C-<return>" 'copilot-accept-completion
                     "C-S-f" 'copilot-accept-completion-by-word
                     "C-S-M-f" 'copilot-accept-completion-by-line
                     ;;"C-S-M-f" 'copilot-accept-completion-by-paragraph
                     "C-n" 'copilot-next-completion
                     "C-p" 'copilot-previous-completion))

;; (use-package copilot-chat
;;   :elpaca (copilot-chat :host github :repo "chep/copilot-chat.el" :files ("*.el"))
;;   :after (request org markdown-mode))

(use-package gptel
  :demand t
  :general
  (
   :keymaps 'override
   "s-p" 'gptel-send
   "s-P" 'gptel))

(use-package gptel-quick
  :ensure (gptel-quick :type git :host github :repo "karthink/gptel-quick")
  :demand t
  :after gptel
  :config
  (keymap-set embark-general-map "?" #'gptel-quick)
  ;; basically keep it until i dismiss
  (setq gptel-quick-timeout 10000))

;; (use-package corsair
;;   :ensure (corsair :type git :host github
;;                    :repo "rob137/Corsair"
;;                    :files ("corsair.el"))
;;   :demand t
;;   :after gptel ; Ensure gptel is loaded before corsair
;;   )

(use-package elysium)
