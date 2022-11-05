(global-set-key (kbd "C-c q") 'auto-fill-mode)

(use-package flyspell
  :config 
  (setq flyspell-abbrev-p t
        flyspell-issue-message-flag nil
        flyspell-issue-welcome-flag nil
        flyspell-mode 1)
  (defun flyspell-goto-previous-error (arg)
    "Go to argpreprevious spelling error."
    (interactive "p")
    (while (not (= 0 arg))
      (let ((pos (point))
            (min (point-min)))
        (if (and (eq (current-buffer) flyspell-old-buffer-error)
                 (eq pos flyspell-old-pos-error))
            (progn
              (if (= flyspell-old-pos-error min)
                  ;; goto beginning of buffer
                  (progn
                    (message "Restarting from end of buffer")
                    (goto-char (point-max)))
                (backward-word 1))
              (setq pos (point))))
        ;; seek the next error
        (while (and (> pos min)
                    (let ((ovs (overlays-at pos))
                          (r '()))
                      (while (and (not r) (consp ovs))
                        (if (flyspell-overlay-p (car ovs))
                            (setq r t)
                          (setq ovs (cdr ovs))))
                      (not r)))
          (backward-word 1)
          (setq pos (point)))
        ;; save the current location for next invocation
        (setq arg (1- arg))
        (setq flyspell-old-pos-error pos)
        (setq flyspell-old-buffer-error (current-buffer))
        (goto-char pos)
        (if (= pos min)
            (progn
              (message "No more miss-spelled word!")
              (setq arg 0))
          ))))

  :general
  (
   :keymaps 'evil-insert-state-map
   (general-chord ",c") 'hydra-flyspell/body
   )
  (
   :states '(normal visual)
   :keymaps 'override
   :prefix ","
   "c" 'hydra-flyspell/body
   )

  :hydra
  (defhydra+ hydra-flyspell ()
    ("b" flyspell-buffer "Spell check" :column "Initiate")
    ("m" flyspell-mode "Toggle mode")

    ("j" flyspell-goto-next-error "Next" :column "Navigate")
    ("k" flyspell-goto-previous-error "Prev")

    ("c" flyspell-correct-at-point "Correct" :column "Action"))
  )

(use-package flyspell-correct
  :after (flyspell) 
  :config 
  )
