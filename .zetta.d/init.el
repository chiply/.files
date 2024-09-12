; bootstrap
(add-to-list 'load-path "~/.files/.zetta.d/source/bootstrap")
(require 'bootstrap)

;; use dash to do the loop
(setq z-files-that-need-creating '("~/.dir-locals.el" "~/.private.el"))

(-each z-files-that-need-creating 'z-touch-maybe)

(setq
 user-files
 '("display.el" "interface.el" "desktop.el" "csv-mode.el"
   "super-save.el" "hud.el" "highlight-indent-guides.el"
   "scroll-bar.el" "display-fill-column-indicator.el"
   "display-line-numbers.el" "undo-tree.el" "face.el"
   "vi-tilde-fringe.el" "treesit.el" "dimmer.el" "focus.el"
   "face-remap.el" "default-text-scale.el" "hl-line.el" "lin.el"
   "hide-mode-line.el" "all-the-icons.el" "remote.el" "minimalize.el"
   "projectile.el" "treemacs-all-the-icons.el" "treemacs.el"
   "treemacs-projectile.el" "tokei.el" "security.el" "grep.el"
   "replace.el" "ag.el" "wgrep.el" "iedit.el" "dap-mode.el"
   "python.el" "web-mode.el" "js2-mode.el" "rjsx-mode.el"
   "emmet-mode.el" "shell.el" "sh-script.el" "foreman.el"
   "foreman_conf.el" "citar.el" "vc.el" "transient.el" "magit.el"
   "forge.el" "git-gutter.el" "docker.el" "dockerfile-mode.el"
   "docker-compose-mode.el" "utility.el" "pocket-reader.el"
   "convention.el" "tree-mode.el" "unidecode.el" "define-word.el"
   "mw-thesaurus.el" "sx.el" "pubmed.el" "helm-wikipedia.el"
   "ace-window.el" "windmove.el" "avy.el" "olivetti.el" "evil.el"
   "evil-anzu.el" "evil-surround.el" "evil-collection.el"
   "evil-exchange.el" "evil-indent-plus.el"
   "evil-search-highlight-persist.el" "evil-fringe-mark.el" "keys.el"
   "dumb-jump.el" "ef-themes.el" "bookmark-view.el" "line-utils.el"
   "dired.el" "sql.el" "sqlite.el" "all-the-icons-dired.el"
   "dired-subtree.el" "dired-ranger.el" "completion.el" "cape.el"
   "dabbrev.el" "recursion-indicator.el" "helm.el" "marginalia.el"
   "orderless.el" "embark.el" "embark-consult.el" "consult.el"
   "tap.el" "tap-block.el" "helpful.el" "elisp-mode.el" "narrow.el"
   "ov.el" "vimish-fold.el" "editing.el" "smartparens.el"
   "hungry-delete.el" "prose.el" "buffer.el" "ibuffer.el" "bufler.el"
   "all-the-icons-ibuffer.el" "bookmark.el" "bookmark+.el"
   "bookmark-in-project.el" "dogears.el" "theme.el" "yaml-mode.el"
   "yaml-path.el" "yaml.el" "yaml-pro.el" "helm-themes.el"
   "text-mode.el" "jmespath.el" "highlight-symbol.el" "terraform.el"
   "ein.el" "adaptive-wrap.el" "xref.el" "flycheck.el"
   "flycheck-indicator.el" "magit-diff-flycheck.el"
   "flycheck-projectile.el" "flycheck-ruff.el" "modern-fringes.el"
   "rainbow-mode.el" "image-mode.el" "browse-url.el" "spray.el"
   "mermaid-mode.el" "minimap.el" "hyperbole.el" "kubernetes-el.el"
   "kubel.el" "git-link.el" "python-pytest.el" "multi-compile.el"
   "compile.el" "unicode-fonts.el" "spinner.el" "fancy-compilation.el"
   "copilot.el"

   "org-ql.el"
   "org-capture.el"
   "org-ref.el"
   ;;"org-modern.el"
   "org.el"
   "ob-mermaid.el"

   "biblio.el"  "lsp.el"
   "lark.el" "yascroll.el" "nyan-mode.el" "gptel.el" "popper.el"
   "highlight.el" "macrostep.el" "obsidian.el" "magneto.el"
   "know-your-http-well.el" "spacetree.el" "vertico.el" "vterm.el"
   "tab-line.el" "window.el" "line.el" "snippets.el"
   "detached.el"
   "ace-mc.el" "json-mode.el" "jsonian.el" "json-processing.el"
   "consult-gh.el" "consult-web.el"

   ;;ADDED
   "speed-type.el" "spray.el" "key-quiz.el" "alert.el" "svg-lib.el"
   "explain-pause-mode.el"
   ;;"kele.el"
   ;;"markdownfmt.el"
   "markdown-toc.el" "color-rg.el" "osx-lib.el" "spotlight.el"
   "restart-emacs" "magit-todos.el"
   "browse-at-remote.el" "mono-complete.el" "rainbow-delimiters.el"
   "magit-file-icons.el" "devdocs.el" "telephone-line.el"
   "corfu.el" "casual-suite.el" "gptel-quick.el" "typescript-ts-mode.el"
   "apheleia.el" "spot4e.el" "symbol-overlay.el"
   "hi-lock.el" "beacon.el"
   ;;"activities.el"
   "cleanup.el"))

;; load user-files and provate lisp code
;; private gets loaded last
(-map (lambda (pkg) (z-load-config-file pkg)) user-files)
(load-file "~/.private.el")


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(bmkp-last-as-first-bookmark-file "~/.files/.zetta.d/bookmarks")
 '(connection-local-criteria-alist
   '(((:application tramp :machine "localhost")
      tramp-connection-local-darwin-ps-profile)
     ((:application tramp :machine "WQN4T69J6P")
      tramp-connection-local-darwin-ps-profile)
     ((:application tramp)
      tramp-connection-local-default-system-profile
      tramp-connection-local-default-shell-profile)
     ((:application eshell) eshell-connection-default-profile)))
 '(connection-local-profile-alist
   '((tramp-connection-local-darwin-ps-profile
      (tramp-process-attributes-ps-args "-acxww" "-o"
                                        "pid,uid,user,gid,comm=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
                                        "-o" "state=abcde" "-o"
                                        "ppid,pgid,sess,tty,tpgid,minflt,majflt,time,pri,nice,vsz,rss,etime,pcpu,pmem,args")
      (tramp-process-attributes-ps-format (pid . number)
                                          (euid . number)
                                          (user . string)
                                          (egid . number) (comm . 52)
                                          (state . 5) (ppid . number)
                                          (pgrp . number)
                                          (sess . number)
                                          (ttname . string)
                                          (tpgid . number)
                                          (minflt . number)
                                          (majflt . number)
                                          (time . tramp-ps-time)
                                          (pri . number)
                                          (nice . number)
                                          (vsize . number)
                                          (rss . number)
                                          (etime . tramp-ps-time)
                                          (pcpu . number)
                                          (pmem . number) (args)))
     (tramp-connection-local-busybox-ps-profile
      (tramp-process-attributes-ps-args "-o"
                                        "pid,user,group,comm=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
                                        "-o" "stat=abcde" "-o"
                                        "ppid,pgid,tty,time,nice,etime,args")
      (tramp-process-attributes-ps-format (pid . number)
                                          (user . string)
                                          (group . string) (comm . 52)
                                          (state . 5) (ppid . number)
                                          (pgrp . number)
                                          (ttname . string)
                                          (time . tramp-ps-time)
                                          (nice . number)
                                          (etime . tramp-ps-time)
                                          (args)))
     (tramp-connection-local-bsd-ps-profile
      (tramp-process-attributes-ps-args "-acxww" "-o"
                                        "pid,euid,user,egid,egroup,comm=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
                                        "-o"
                                        "state,ppid,pgid,sid,tty,tpgid,minflt,majflt,time,pri,nice,vsz,rss,etimes,pcpu,pmem,args")
      (tramp-process-attributes-ps-format (pid . number)
                                          (euid . number)
                                          (user . string)
                                          (egid . number)
                                          (group . string) (comm . 52)
                                          (state . string)
                                          (ppid . number)
                                          (pgrp . number)
                                          (sess . number)
                                          (ttname . string)
                                          (tpgid . number)
                                          (minflt . number)
                                          (majflt . number)
                                          (time . tramp-ps-time)
                                          (pri . number)
                                          (nice . number)
                                          (vsize . number)
                                          (rss . number)
                                          (etime . number)
                                          (pcpu . number)
                                          (pmem . number) (args)))
     (tramp-connection-local-default-shell-profile
      (shell-file-name . "/bin/sh") (shell-command-switch . "-c"))
     (tramp-connection-local-default-system-profile
      (path-separator . ":") (null-device . "/dev/null"))
     (eshell-connection-default-profile (eshell-path-env-list))))
 '(custom-safe-themes
   '("4c7228157ba3a48c288ad8ef83c490b94cb29ef01236205e360c2c4db200bb18"
     default))
 '(ede-project-directories
   '("/Users/redacted/source_code/workflow-activity-registry"))
 '(helm-minibuffer-history-key "M-p")
 '(org-agenda-files '("/Users/redacted/.files/org-roam/daily/agenda.org"))
 '(org-fold-core-style 'overlays))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
