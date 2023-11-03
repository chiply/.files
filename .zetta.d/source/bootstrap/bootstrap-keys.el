;; for binding keys
(use-package general)

;; for key chords, although a better thought of as melodies, becuase
;; they involve sequential presses of keys
(use-package key-chord
  :config
  (setq key-chord-two-keys-delay .05 key-chord-one-key-delay .05)
  (key-chord-mode 1)
  )

;; provides hints
(use-package which-key
  :config

  (defun z-cursor-in-which-key-slot ()
    (and
     (eq 0 (window-parameter (selected-window) 'window-slot))
     (eq 'top (window-parameter (selected-window) 'window-side))
     )
    )

  (setq which-key-popup-type 'custom)
  (defun which-key-custom-popup-max-dimensions-function (ignore)
    (cons
     (which-key--height-or-percentage-to-height
      which-key-side-window-max-height)
     (frame-width)))

  (defun fit-horizonatally ()
    (let ((fit-window-to-buffer-horizontally t))
      (fit-window-to-buffer)))

  (defun which-key-custom-show-popup-function (act-popup-dim)
    (let* ((alist `((window-width . fit-horizontally)
                    (window-height . fit-window-to-buffer)
                    (side . ,(if (z-cursor-in-which-key-slot)
                               (intern "bottom")
                                 (intern "top")
                               ))
                    (slot . 0)
                    )))
      (if (get-buffer-window which-key--buffer)
          (display-buffer-reuse-window which-key--buffer alist)
        (display-buffer-in-side-window which-key--buffer alist))
      ))

  (defun which-key-custom-hide-popup-function ()
    (when (buffer-live-p which-key--buffer)
      (quit-windows-on which-key--buffer)))

  (setq
   ;; Allow C-h to trigger which-key before it is done automatically
   which-key-show-early-on-C-h t
   ;; make sure which-key doesn't show normally but refreshes quickly
   ;; after it is triggered.
   which-key-idle-delay 10000 which-key-idle-secondary-delay 0.05
   ;; docs
   which-key-show-docstrings t which-key-max-description-length 100
   ;; evil
   which-key-allow-evil-operators t
   ;; misc
   suggest-key-bindings 0
   which-key-show-major-mode t
   ;; need to set this to 0 if youre using the minibuffer
   echo-keystrokes 1
   which-key-max-display-columns 2
   ;; custom functions
   which-key-custom-popup-max-dimensions-function 'which-key-custom-popup-max-dimensions-function
   which-key-custom-show-popup-function 'which-key-custom-show-popup-function
   which-key-custom-hide-popup-function 'which-key-custom-hide-popup-function
   )

  (which-key-mode 1)
  )


(provide 'bootstrap-keys)


