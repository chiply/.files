(setq read-process-output-max (* 64 1024 1024))
(setq process-adaptive-read-buffering nil)
;;(let ((process-connection-type nil))
  ;;(async-shell-command command buffer))

;; remembering sudo pass
(require 'em-tramp)
(setq password-cache t)
(setq password-cache-expiry 3600)

(use-package shell
  :straight nil
  :demand t

  :hydra
  (defhydra+ hydra-scroll ()
    ("," :exit t "Exit")
    ("l" (lambda () (interactive)
           (scroll-left 5 nil)) :column "Horizontal")
    ("h" (lambda () (interactive)
           (scroll-right 5 nil)))
    ("k" (lambda () (interactive)
           (scroll-down 5 )) :column "Vertical")
    ("j" (lambda () (interactive)
           (scroll-up 5)))
    ("gg" evil-goto-first-line :column "Evil")
    ("G" evil-goto-line)
    )

  :general
  (
   :keymaps 'override
   "s-S" 'hydra-scroll/body
   )
  (
   :keymaps '(shell-mode-map)
   "C" 'z-highlight-phrases
   )

  :hook (shell-mode . (lambda () (progn
                                   (toggle-truncate-lines 1)
                                   (z-highlight-phrases)
                                   )))
  )


(setq shell-file-name "zsh")
(setq shell-command-switch "-c")
