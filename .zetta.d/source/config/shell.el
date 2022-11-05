;; remembering sudo pass
(require 'em-tramp)
(setq password-cache t)
(setq password-cache-expiry 3600)


(use-package sh-script
  :straight nil
  :demand t

  :general
  (
   :states '(normal visual)
   :keymaps '(sh-mode-map)
   "C-e" 'er/expand-region
   )
  
  )


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
   :states '(normal visual insert)
   :keymaps 'override
   "s-S" 'hydra-scroll/body
   )
  (
   :states '(normal visual insert)
   :keymaps '(shell-mode-map)
   "C" 'z-highlight-phrases
   )

  :hook (shell-mode . (lambda () (progn
                                   (toggle-truncate-lines 1)
                                   (z-highlight-phrases)
                                   )))
  )

(use-package vterm
  :demand t
  :init


  (defun z-soda-prompt-term-buffer ()
    (let ((mode-buffers (-map
                         (lambda (x) (buffer-name x))
                         (z-soda-list-mode-buffers "\\term-mode*"))))
      (completing-read "Proces Buffer: " mode-buffers)
      ))



  (defun z-soda-create-and-display-term (buf-or-mode-name)
    (interactive)
    (let* ((buf (current-buffer))
           (program (completing-read
                     "Choose a program: "
                     '("python3" "sqlite3" "zsh" "bash" "ipython")))
           (nm (concat "*"
                       program
                       "-"
                       (if (4mn-get-tramp-context--hostname)
                           (concat "[r: " (4mn-get-tramp-context--hostname) "]")
                         "")
                       (if (4mn-get-tramp-context--containername)
                           (concat "[d:" (4mn-get-tramp-context--containername) "]")
                         "")
                       "--"
                       buf-or-mode-name "*"))
           (filepath (if (string-match ":" (or (projectile-project-root) default-directory))
                         (nth 0 (last (split-string (or (projectile-project-root) default-directory) ":")))
                       (or (projectile-project-root) default-directory)))
           )
      (let ((container (4mn-get-tramp-context--containername))
            (host (4mn-get-tramp-context--hostname)))
        (cond
         ;; needs to be first as it is more specific than the below
         ((and (member "ssh" (4mn-get-tramp-hop-types))
               (member "docker" (4mn-get-tramp-hop-types)))
          ;; then create the buffer on local and docker exec into container
          (let ((default-directory "~/"))
            (with-current-buffer (get-buffer-create nm)
              (vterm-mode)
              (setq-local foreman-ssh t)
              (setq-local foreman-docker t))
            (process-send-string
             nm
             (format "ssh %s \n" host))
            (process-send-string
             nm
             (format "docker exec -it %s bash\n" container))
            (process-send-string
             nm
             (format "cd %s \n" filepath))
            ))
         ((member "docker" (4mn-get-tramp-hop-types))
          ;; then create the buffer on local and docker exec into container
          (let ((default-directory "~/"))
            (with-current-buffer (get-buffer-create nm)
              (vterm-mode)
              (setq-local foreman-docker t)
              (setq-local foreman-ssh nil)
              )
            (process-send-string
             nm
             (format "docker exec -it %s bash\n" container))
            (process-send-string
             nm
             (format "cd %s \n" filepath))
            ))
         ((member "ssh" (4mn-get-tramp-hop-types))
          ;; then create the buffer on local and docker exec into container
          (let ((default-directory "~/"))
            (with-current-buffer (get-buffer-create nm)
              (vterm-mode)
              (setq-local foreman-docker nil)
              (setq-local foreman-ssh t))
            (process-send-string
             nm
             (format "ssh %s \n" host))
            (process-send-string
             nm
             (format "cd %s \n" filepath))))

         ;; then just create the buffer as usual
         (t
          (with-current-buffer (get-buffer-create nm)
            (vterm-mode)
            (setq-local foreman-docker nil)
            (setq-local foreman-ssh nil)))
         )
        )


      (process-send-string nm (concat "clear\n" program "\n"))

      (switch-to-buffer buf)
      (display-buffer nm)
      )
    )

  :config
  (setq vterm-shell "zsh")

  (setq vterm-color-palette [vterm-color-black
                             font-lock-comment-face
                             vterm-color-white
                             vterm-color-underline
                             vterm-color-underline
                             vterm-color-underline
                             vterm-color-underline
                             vterm-color-underline
                             ])

  (add-to-list 'brushup-styles
               '(progn
                  (set-face-attribute 'vterm-color-magenta nil
                                    :foreground brushup-fg
                                    :background brushup-bg-3
                                    )
                  (set-face-attribute 'vterm-color-black nil
                                    :foreground brushup-fg
                                    :background brushup-bg-3
                                    )
                  (set-face-attribute 'vterm-color-yellow nil
                                    :foreground brushup-fg
                                    :background brushup-bg-3
                                    )
                  (set-face-attribute 'vterm-color-yellow nil
                                    :foreground brushup-fg
                                    :background brushup-bg-3
                                    )
                  (set-face-attribute 'term-color-yellow nil
                                    :foreground brushup-fg
                                    :background brushup-bg-3
                                    )
                  (set-face-attribute 'term-color-magenta nil
                                    :foreground brushup-fg
                                    :background brushup-bg-3
                                    )
                  (set-face-attribute 'term-color-bright-yellow nil
                                    :foreground brushup-fg
                                    :background brushup-bg-3
                                    )
                  )
               )

  :display
  (z-side "^\\*zsh*" 'bottom)
  (z-side "^\\*bash*" 'bottom)
  (z-side "^\\*python3*" 'bottom 1)
  (z-side "^\\*ipython*" 'bottom 1)
  (z-side "^\\*ssh*" 'bottom 1)
  (z-side "^\\*sqlite3*" 'bottom 2)

  :general
  (
   :states '(insert)
   :keymaps '(vterm-mode-map)
   "C-s" 'vterm-send-C-s
   )
  (
   :states '(normal)
   :keymaps '(vterm-mode-map)
   "C-b" 'vterm-send-C-b
   "C-k" 'vterm-send-up
   "C-j" 'vterm-send-down
   )

  :hydra
  (defhydra+ hydra-run ()
    ("s" (lambda ()
           (interactive)
           (z-soda-drink (quote z-soda-create-and-display-term) (z-soda-prompt-term-buffer))
           ) "shell" :exit t)
    ("S" (lambda () (interactive) (z-soda-cap "\\term-mode*" 1)) "Terminal" )

    )

  :hook (
         (vterm-mode . (lambda ()
                         (setq global-hl-line-mode nil)
                         (text-scale-set -1)
                         (toggle-truncate-lines 1)
                         (display-line-numbers-mode 1)
                         ))
         ((vterm-mode shell-mode) . tab-line-mode)
         )
  )

(use-package foreman
  :straight nil
  :load-path "~/.files/.zetta.d/source/zettapkg/foreman"
  :demand t

  :display
  (z-side "^\\*4t0*" 'top)
  (z-side "^\\*4t1*" 'top 1)
  (z-side "^\\*4b0*" 'bottom)
  (z-side "^\\*4r0*" 'right)
  
  


  )
