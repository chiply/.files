
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
   "treemacs-all-the-icons.el" "treemacs.el" "treemacs-projectile.el"
   "tokei.el" "security.el" "grep.el" "replace.el" "ag.el" "wgrep.el"
   "iedit.el" "dap-mode.el" "python.el" "web-mode.el" "js2-mode.el"
   "rjsx-mode.el" "emmet-mode.el" "shell.el" "sh-script.el"
   "foreman.el" "foreman_conf.el" "citar.el" "vc.el" "transient.el"
   "magit.el" "forge.el" "git-gutter.el" "docker.el"
   "dockerfile-mode.el" "docker-compose-mode.el" "utility.el"
   "pocket-reader.el" "convention.el" "tree-mode.el" "unidecode.el"
   "define-word.el" "mw-thesaurus.el" "sx.el" "pubmed.el"
   "helm-wikipedia.el" "ace-window.el" "windmove.el" "avy.el"
   "olivetti.el" "winds.el" "evil.el" "evil-anzu.el" "evil-matchit.el"
   "evil-surround.el" "evil-collection.el" "evil-exchange.el"
   "evil-indent-plus.el" "evil-search-highlight-persist.el" "keys.el"
   "dumb-jump.el" "bookmark-view.el" "views.el" "line-utils.el"
   "sql.el" "sqlite.el" "all-the-icons-dired.el" "dired-subtree.el"
   "dired-ranger.el" "completion.el" "cape.el" "dabbrev.el"
   "recursion-indicator.el" "helm.el" "marginalia.el" "orderless.el"
   "embark.el" "embark-consult.el" "magneto.el" "consult.el" "tap.el"
   "tap-block.el" "helpful.el" "elisp-mode.el" "narrow.el" "ov.el"
   "vimish-fold.el" "editing.el" "smartparens.el" "hungry-delete.el"
   "prose.el" "buffer.el" "ibuffer.el" "bufler.el"
   "all-the-icons-ibuffer.el" "bookmark.el" "bookmark+.el"
   "bookmark-in-project.el" "dogears.el" "theme.el" "detached.el"
   "yaml-mode.el" "yaml-path.el" "yaml.el" "yaml-pro.el"
   "json-snatcher.el" "jsonian.el" "eww.el" "helm-themes.el"
   "text-mode.el" "jmespath.el" "highlight-symbol.el" "terraform.el"
   "ein.el" "adaptive-wrap.el" "flycheck.el" "flycheck-indicator.el"
   "flycheck-pycheckers.el" "magit-diff-flycheck.el"
   "flycheck-projectile.el" "hercules.el" "evil-fringe-mark.el"
   "modern-fringes.el" "rainbow-mode.el" "image-mode.el"
   "browse-url.el" "minibar.el" "spray.el" "mermaid-mode.el"
   "minimap.el" "hyperbole.el" "kubernetes-el.el" "kubel.el"
   "git-link.el" "python-pytest.el" "multi-compile.el" "spinner.el"
   "compile.el" "fancy-compilation.el" "copilot.el" "org-ql.el"
   "org-capture.el" "org-roam.el" "org-roam-ui.el"
   "org-roam-timestamps.el" "org-ref.el" "org-modern.el" "biblio.el"
   "org.el" "citar-org-roam.el" "elfeed-org.el" "ob-mermaid.el"
   "eaf.el" "cleanup.el"))


;;"org-noter.el" "pdf-tools.el" "org-pdftools.el" "org-noter-pdftools.el"


;; load user-files and provate lisp code
(-map (lambda (pkg) (z-load-config-file pkg)) user-files)
(load-file "~/.private.el")

;; z-lisp. slowly migrating from above files into z-lisp
(load-file "~/.files/.zetta.d/source/config/use-package-file.el")

(add-to-list
 'load-path
 (expand-file-name
  (concat user-emacs-directory "source/z-lisp")))
(setq
 user-files-ext-features
 '(
   "z-tree-sitter" "z-elfeed" "z-org-agenda" "z-dired" "z-lsp"
   "z-vertico" "z-vterm" "z-tab-line" "z-window"
   "z-org-super-agenda" "z-snippets" "z-line"
   ))
;; require all the features
(-map (lambda (feature) (require (intern feature))) user-files-ext-features)


