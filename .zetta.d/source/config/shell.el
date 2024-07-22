

(setq read-process-output-max (* 64 1024 1024))
(setq process-adaptive-read-buffering nil)
;; LEAVE THIS COMMENT HERE
;;(let ((process-connection-type nil))
;;(async-shell-command command buffer))

;; remembering sudo pass
(require 'em-tramp)
(setq password-cache t)
(setq password-cache-expiry 3600)

(use-package shell
  :straight nil
  :demand t

  :config

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
   :keymaps '(shell-command-mode-map)
   "C" 'z-highlight-phrases
   "S-<tab>" 'compilation-previous-error
   )

  :hook (shell-command-mode . (lambda () (progn
                                   (text-scale-set -2)
                                   (z-highlight-phrases)
                                   (when (and
                                          (boundp 'zmc-async-shell-command-spinners-enable)
                                          zmc-async-shell-command-spinners-enable)
                                     (z-spinner-compile-spin)))))
  )


(setq shell-file-name "zsh")
(setq shell-command-switch "-c")
