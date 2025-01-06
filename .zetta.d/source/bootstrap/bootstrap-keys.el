;; for binding keys
(use-package general :demand t :ensure (:wait t))

;; for key "chords", although a better thought of as "melodies",
;; becuase they involve sequential presses of keys
(use-package key-chord
  :config
  (setq key-chord-two-keys-delay .05 key-chord-one-key-delay .05)
  (key-chord-mode 1))

;; provides hints
(use-package which-key
  :demand t
  :config

  (defun z-cursor-in-which-key-slot ()
    (and
     (eq 0 (window-parameter (selected-window) 'window-slot))
     (eq 'top (window-parameter (selected-window) 'window-side))
     ))

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
      (display-buffer-no-window which-key--buffer alist)))

  (defun which-key-custom-hide-popup-function ()
    (when (buffer-live-p which-key--buffer)
      (quit-windows-on which-key--buffer)))

  (setq
   ;; more useful hinting as it remains open (at least the way i use
   ;; it)
   which-key-persistent-popup t
   ;; include more in the which key buffer
   which-key-compute-remaps t
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
  ;; because which-ley-mode sets prefix-help-command to which-key-C-h-dispatch
  ;;(setq prefix-help-command #'embark-prefix-help-command)

  (defun which-key--create-buffer-and-show
      (&optional prefix-keys from-keymap filter prefix-title)
    "Fill `which-key--buffer' with key descriptions and reformat.
Finally, show the buffer."
    (let ((start-time (current-time))
          (formatted-keys (which-key--get-bindings
                           ;; updated -- added t to show the full keymap
                           prefix-keys from-keymap filter t))
          (prefix-desc (key-description prefix-keys)))
      (cond ((null formatted-keys)
             (message "%s-  which-key: There are no keys to show" prefix-desc))
            ((listp which-key-side-window-location)
             (setq which-key--last-try-2-loc
                   (apply #'which-key--try-2-side-windows
                          formatted-keys prefix-keys prefix-title
                          which-key-side-window-location)))
            (t (setq which-key--pages-obj
                     (which-key--create-pages
                      formatted-keys prefix-keys prefix-title))
               (which-key--show-page)))
      (which-key--debug-message
       "On prefix \"%s\" which-key took %.0f ms." prefix-desc
       (* 1000 (float-time (time-since start-time))))))

  )



(use-package meow
  :init
  ;; copied from docs
  (defun meow-setup ()
    (setq meow-cheatsheet-layout meow-cheatsheet-layout-qwerty)
    (meow-motion-overwrite-define-key
     '("j" . meow-next)
     '("k" . meow-prev)
     '("<escape>" . ignore))
    (meow-leader-define-key
     ;; SPC j/k will run the original command in MOTION state.
     '("j" . "H-j")
     '("k" . "H-k")
     ;; Use SPC (0-9) for digit arguments.
     '("1" . meow-digit-argument)
     '("2" . meow-digit-argument)
     '("3" . meow-digit-argument)
     '("4" . meow-digit-argument)
     '("5" . meow-digit-argument)
     '("6" . meow-digit-argument)
     '("7" . meow-digit-argument)
     '("8" . meow-digit-argument)
     '("9" . meow-digit-argument)
     '("0" . meow-digit-argument)
     '("/" . meow-keypad-describe-key)
     '("?" . meow-cheatsheet))
    (meow-normal-define-key
     '("0" . meow-expand-0)
     '("9" . meow-expand-9)
     '("8" . meow-expand-8)
     '("7" . meow-expand-7)
     '("6" . meow-expand-6)
     '("5" . meow-expand-5)
     '("4" . meow-expand-4)
     '("3" . meow-expand-3)
     '("2" . meow-expand-2)
     '("1" . meow-expand-1)
     '("-" . negative-argument)
     '(";" . meow-reverse)
     ;; changed to allow for the prefix key
     '("." . meow-inner-of-thing)
     '(">" . meow-bounds-of-thing)
     '("[" . meow-beginning-of-thing)
     '("]" . meow-end-of-thing)
     '("a" . meow-append)
     '("A" . meow-open-below)
     '("b" . meow-back-word)
     '("B" . meow-back-symbol)
     '("c" . meow-change)
     '("d" . meow-delete)
     '("D" . meow-backward-delete)
     '("e" . meow-next-word)
     '("E" . meow-next-symbol)
     '("f" . meow-find)
     '("g" . meow-cancel-selection)
     '("G" . meow-grab)
     '("h" . meow-left)
     '("H" . meow-left-expand)
     '("i" . meow-insert)
     '("I" . meow-open-above)
     '("j" . meow-next)
     '("J" . meow-next-expand)
     '("k" . meow-prev)
     '("K" . meow-prev-expand)
     '("l" . meow-right)
     '("L" . meow-right-expand)
     '("m" . meow-join)
     '("n" . meow-search)
     '("o" . meow-block)
     '("O" . meow-to-block)
     '("p" . meow-yank)
     '("q" . meow-quit)
     '("Q" . meow-goto-line)
     '("r" . meow-replace)
     '("R" . meow-swap-grab)
     '("s" . meow-kill)
     '("t" . meow-till)
     '("u" . meow-undo)
     '("U" . meow-undo-in-selection)
     '("v" . meow-visit)
     '("w" . meow-mark-word)
     '("W" . meow-mark-symbol)
     '("x" . meow-line)
     '("X" . meow-goto-line)
     '("y" . meow-save)
     '("Y" . meow-sync-grab)
     '("z" . meow-pop-selection)
     '("'" . repeat)
     '("<escape>" . ignore)))

  :config
  (setq meow-keypad-start-keys
        '((?c . ?c)
          (?h . ?h)
          (?x . ?x)
          ;; launch-map
          (?, . ?,)))

  ;; TODO -- would this make more sense as C-x and to use it as the
  ;; launcher?  maybe but keep this around for now
  (setq meow-keypad-leader-dispatch "C-c")
  
  (general-define-key
   :keymaps '(meow-insert-state-keymap)
   ;;"C-;" 'evil-normal-state
   (general-chord "kj") 'meow-insert-exit
   (general-chord "jk") 'meow-insert-exit)
  )


(defun z-state-meow ()
  (interactive)
  (evil-mode -1)
  (meow-setup)
  (meow-global-mode 1)
  (message "meow enabled"))

(defun z-state-evil ()
  (interactive)
  (evil-mode t)
  (meow-global-mode -1)
  (message "evil enabled"))

(defun z-state-emacs ()
  (interactive)
  (evil-mode -1)
  (meow-global-mode -1)
  (message "emacs state enabled"))

(general-define-key
 :keymaps 'override
 "s-z m" 'z-state-meow
 "s-z e" 'z-state-evil
 "s-z E" 'z-state-emacs)

;; There are different key systems that can be used.  emacs, evil,
;; meow.  the issue is that evil and meow are modal editing systems
;; while emacs is not.  in modal editing systems there is a notion of
;; insert state (eg entering text) and non-insert states.  modal
;; editing systems achieve short key sequences relative to systems
;; like emacs built keys because of their non-insert states.  The
;; issue this creates for keybindings is that you will have keys (like
;; ,f for find-file) that will need to be bound in non-insert states,
;; but not in insert states.  This block of codes simplifies setup by
;; defining a prefix-command, 'launch-map, and binding the launch key
;; (,) to this prefix.  Then, the keymap is bound to , in all modal
;; keymaps (defined in z-modal-states-non-insert).  In this way, code
;; elsewhere in the config can declare keybindings that apply ACROSS
;; MULTIPLE MODAL EDITING SYSTEMS AND DEFAUKT KEYBINDINGS, by simply
;; defining a keysequence on the 'launch-map, as opposed to defining 3
;; separate forms that define the keys for non-insert, insert and
;; emacs states.  This setup is robust to the addition of new modal
;; editing systems such as

;; note on easing migration -- as I am migrating from evil to meow, I
;; can still rely on evil muscle memory, or even differential
;; functionality, by quick dropping into evil mode.  This is useful
;; not only for easing migration, but as a general feature of my
;; configuration. Can almost consider this as a meta state.  Maybe
;; 'modal state'.  And the idea would be to live in meow MOST of the
;; time, while only swithcing to evil or emacs when necessary.

;; define the launch-map
(define-prefix-command 'launch-map)
(defvar launch-key ",")

(defvar z-modal-states-insert '(evil-insert-state-map
                                meow-insert-state-keymap))

(defvar z-modal-states-non-insert '(evil-normal-state-map
                                    evil-visual-state-map
                                    meow-beacon-state-keymap
                                    meow-motion-state-keymap
                                    meow-normal-state-keymap))

;; Bind launch map to , in non insert states
(general-define-key :keymaps z-modal-states-non-insert launch-key 'launch-map)

;; Bind launch map to C-, in insert states.  Compatible with meow and embark-become
(general-define-key (concat "C-" launch-key) 'launch-map)


;; then actually edit code to use direct general bindings instead of my custom function
;; define code for easily switching between modes -- use whatever is bound to c-z but make it cylce through

;; not used, but may be used in the future if general chord will be used
;; (defun define-launch-key (pairs)
;;   "Creates opinionated set of general-define-key forms for defining
;;   the keybindings provided in PAIRS to evil-mode and meow-mode.  Each
;;   of these modes requires separate keybindings in insert and
;;   non-insert modes, which is made possible by general-chord.  So to
;;   define a complete set of global keybindings for, let's say
;;   find-file, one would need to create 4 separate forms per set of
;;   PAIRS, which is impractical.  This function offers syntactic sugar."
;;   (eval
;;    `(progn
;;       ;; non-insert
;;       ,(append '(general-define-key) '(:keymaps 'launch-map) pairs)
;;       ;; insert
;;       ,(append '(general-define-key)
;;                '(:keymaps z-modal-states-insert)
;;                (mapcar
;;                 (lambda (x)
;;                   (if (eq (mod (seq-position pairs x) 2) 1)
;;                       x `(general-chord ,(concat launch-key x))))
;;                 pairs)))))

(provide 'bootstrap-keys)
