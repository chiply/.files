;;; init.el --- kb-hub: lean terminal Emacs for mobile editing -*- lexical-binding: t -*-
;; Source of truth: ~/.files/hub/emacs/init.el, deployed by hub-deploy —
;; edits made directly on the hub get overwritten. After deploying config
;; changes: systemctl --user restart emacs (kills live sessions; pick a
;; quiet moment).

;; Keep all emacs droppings out of the synced tree (~/kb); .stignore
;; covers them too, but belt and suspenders.
(setq backup-directory-alist '(("." . "~/.emacs.d/backups/"))
      auto-save-file-name-transforms '((".*" "~/.emacs.d/autosaves/" t))
      create-lockfiles nil
      backup-by-copying t
      delete-old-versions t)

(setq custom-file "~/.emacs.d/custom.el")
(load custom-file t)

;; async native-comp lint findings in third-party/built-in code are not
;; actionable; log to *Warnings* without popping a window over the phone UI
(setq native-comp-async-report-warnings-errors 'silent)

;; Packages: package.el + built-in use-package (emacs 29)
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)
(unless package-archive-contents (package-refresh-contents))
(setq use-package-always-ensure t)
(require 'use-package)

;; Modal editing: fewer chords is the whole game on a phone keyboard.
(use-package evil
  :init (setq evil-want-C-u-scroll t
              evil-undo-system 'undo-redo)
  :config (evil-mode 1))

;; Terminal niceties
(xterm-mouse-mode 1)          ; touch taps move point / scroll
(menu-bar-mode -1)
(column-number-mode 1)
(setq ring-bell-function 'ignore)
(fido-vertical-mode 1)        ; lightweight completion, no packages

;; Org: reading and plain-text appends; deliberately no heavy machinery
(setq org-startup-folded 'content
      org-return-follows-link t)
(add-hook 'org-mode-hook #'visual-line-mode)
(add-hook 'text-mode-hook #'visual-line-mode)

;; Quick entry points
(defun kb ()
  "Open the kb folder in dired."
  (interactive)
  (dired "~/kb"))

(defun kb-inbox ()
  "Jump to the end of the shared inbox for a quick append."
  (interactive)
  (find-file "~/kb/inbox.org")
  (goto-char (point-max)))
