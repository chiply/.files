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

  ;; fixes unreadable situation -- comes out brown by default
  ;; note this is dependent on the terminal that launches emacs, I'm
  ;; using iterm2
  (add-to-list 'brushup-styles
               '(progn
                  (set-face-attribute 'vterm-color-yellow nil
                                      :foreground brushup-fg
                                      :background brushup-bg-3)))


  ;; set font in vterm -- note some fonts break certain applications.
  ;; Ex: Vulf font breaks the k9s cli

  (add-hook 'vterm-mode-hook 'my-buffer-face-mode-pt-mono)


  :display
  ;;(z-side "^\\*zsh*" 'bottom)
  ;;(z-side "^\\*bash*" 'bottom)
  ;;(z-side "^\\*python3*" 'bottom 1)
  ;;(z-side "^\\*ipython*" 'bottom 1)
  ;;(z-side "^\\*ssh*" 'bottom 1)
  ;;(z-side "^\\*sqlite3*" 'bottom 2)

  :general
  (
   :states '(insert)
   :keymaps '(vterm-mode-map)
   "C-s" 'vterm-send-C-s
   "C-x" 'vterm-send-C-x
   "<escape>" 'vterm-send-escape
   "C-u" 'universal-argument
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
  

  :hook ((vterm-mode . (lambda ()
                         (setq global-hl-line-mode nil)
                         (toggle-truncate-lines 1) (display-line-numbers-mode 1)))
         ((vterm-mode shell-command-mode) . tab-line-mode))
  )
