

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
  :general
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
