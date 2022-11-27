;; bootstrap
(add-to-list 'load-path "~/.files/.zetta.d/source/bootstrap")
(require 'bootstrap)

;; move to zettafn

;; use dash to do the loop
(setq
 z-files-that-need-creating
 '("~/.dir-locals.el"
   "~/.private.el"
   "~/.files/org-roam/daily/agenda.org"
   "~/.files/org-roam/daily/agenda.org_archive"
   ;; pub doesn't really need to be written as its in vc
   "~/.files/org-roam/daily/agenda_pub.org"
   "~/.files/org-roam/daily/agenda_pub.org_archive"
   "~/.files/org-roam/daily/sprint.org"
   "~/.files/org-roam/daily/sprint.org_archive"
   ;; NOTE -- not sprint_pub as print is inherently private to the
   ;; machine
   "~/.files/org-roam/private"
   "~/.files/org-roam/public"
   ))

(-each z-files-that-need-creating 'z-touch-maybe)


(setq
 user-files
 '("display.el" "interface.el" "desktop.el" "csv-mode.el"
   "super-save.el" "hud.el" "highlight-indent-guides.el"
   "scroll-bar.el" "display-fill-column-indicator.el"
   "display-line-numbers.el" "linum-relative.el" "undo-tree.el"
   "visual-fill-column.el" "face.el" "tree-sitter.el"
   "tree-sitter-langs.el" "dimmer.el" "focus.el" "face-remap.el"
   "default-text-scale.el" "hl-line.el" "lin.el" "hide-mode-line.el"
   "all-the-icons.el" "remote.el" "minimalize.el" "projectile.el"
   "treemacs.el" "treemacs-projectile.el" "treemacs-all-the-icons.el"
   "tokei.el" "security.el" "grep.el" "replace.el" "ag.el" "wgrep.el"
   "iedit.el" "lsp.el" "dap-mode.el" "python.el" "web-mode.el"
   "js2-mode.el" "rjsx-mode.el" "emmet-mode.el" "shell.el"
   "foreman_conf.el" "citar.el" "vc.el" "transient.el" "magit.el"
   "forge.el" "git-gutter.el" "docker.el" "dockerfile-mode.el"
   "docker-compose-mode.el" "utility.el" "pocket-reader.el"
   "convention.el" "tree-mode.el" "unidecode.el" "define-word.el"
   "mw-thesaurus.el" "sx.el" "pubmed.el" "helm-wikipedia.el"
   "elfeed.el" "window.el" "ace-window.el" "windmove.el" "avy.el"
   "olivetti.el" "winds.el" "magneto.el" "evil.el" "evil-anzu.el"
   "evil-matchit.el" "evil-surround.el" "evil-collection.el"
   "evil-exchange.el" "evil-indent-plus.el"
   "evil-search-highlight-persist.el" "keys.el" "consult-lsp.el"
   "dumb-jump.el" "bookmark-view.el" "views.el" "line-utils.el"
   "tab-line.el" "line.el" "sql.el" "sqlite.el" "dired.el"
   "all-the-icons-dired.el" "dired-subtree.el" "dired-ranger.el"
   "completion.el" "cape.el" "dabbrev.el" "recursion-indicator.el"
   "helm.el" "marginalia.el" "orderless.el" "vertico.el" "embark.el"
   "embark-consult.el" "consult.el" "tap.el" "tap-block.el"
   "helpful.el" "elisp-mode.el" "narrow.el" "ov.el" "vimish-fold.el"
   "editing.el" "smartparens.el" "hungry-delete.el" "prose.el"
   "buffer.el" "ibuffer.el" "bufler.el" "all-the-icons-ibuffer.el"
   "bookmark.el" "bookmark+.el" "bookmark-in-project.el" "dogears.el"
   "theme.el" "detached.el" "yaml-mode.el" "yaml-path.el" "yaml.el"
   "yaml-pro.el" "json-snatcher.el" "jsonian.el" "eww.el"
   "helm-themes.el" "text-mode.el" "jmespath.el" "highlight-symbol.el"
   "terraform.el" "ein.el" "adaptive-wrap.el" "flycheck.el"
   "flycheck-indicator.el" "flycheck-pycheckers.el"
   "magit-diff-flycheck.el" "flycheck-projectile.el" "hercules.el"
   "evil-fringe-mark.el" "modern-fringes.el" "rainbow-mode.el"
   "image-mode.el"  "browse-url.el" "cleanup.el")
 )

;; load user-files and provate lisp code
(-map (lambda (pkg) (z-load-config-file pkg)) user-files)
(load-file "~/.private.el")

;; loading some packages here until I figure out the issues
(defun z-tmp-load-org-and-snip ()
  (interactive)
  (let ((user-files '("snippets.el" "org.el" "citar-org-roam.el" "elfeed-org.el" "ob-mermaid.el" "eaf.el")))
    (-map (lambda (pkg) (z-load-config-file pkg)) user-files)
    )
  )

(defun z-tmp-load-whole-init ()
  (interactive)
  (z-load-config-file (concat user-emacs-directory "init.el"))
  (z-tmp-load-org-and-snip)
  ;;(z-ws-cfg-bv-new-bv "default")
  )

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("c505ae23385324c21821b24c9cc1d68d8da6f3cfb117eb18826d146b8ec01b15" "4a288765be220b99defaaeb4c915ed783a9916e3e08f33278bf5ff56e49cbc73" "de43637da82e6127fd76472ae58682927f25693fcccb16161be12f2331bcc7cc" default)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(fill-column-indicator ((t (:foreground "gray80" :weight normal))))
 '(multi-magit-repo-heading ((t (:inherit magit-section-heading :box nil))))
 '(speedbar-selected-face ((t (:foreground "#008B45" :underline t)))))

