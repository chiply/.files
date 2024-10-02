(use-package vc
  :straight nil
  :demand t

  :config
  (setq vc-follow-symlinks t)

  :evil
  (evil-set-initial-state 'magit-blame-mode 'emacs)
  (evil-set-initial-state 'git-commit-mode 'emacs)
  (evil-set-initial-state 'git-blame-mode 'emacs)
  (evil-set-initial-state 'git-commit-mode 'insert)
  (evil-set-initial-state 'magit-log-edit-mode 'insert)


  :display

  ;;(z-side "^\\*vc-diff*" 'right)

  :hydra
  (defhydra+ unpackaged/smerge-hydra
    (:color pink :hint nil :post (smerge-auto-leave))
    "
^Move^       ^Keep^               ^Diff^                 ^Other^
^^-----------^^-------------------^^---------------------^^-------
_n_ext       _b_ase               _<_: upper/base        _C_ombine
_p_rev       _u_pper              _=_: upper/lower       _r_esolve
^^           _l_ower              _>_: base/lower        _k_ill current
^^           _a_ll                _R_efine
^^           _RET_: current       _E_diff
"
    ("n" smerge-next)
    ("p" smerge-prev)
    ("b" smerge-keep-base)
    ("u" smerge-keep-upper)
    ("l" smerge-keep-lower)
    ("a" smerge-keep-all)
    ("RET" smerge-keep-current)
    ("\C-m" smerge-keep-current)
    ("<" smerge-diff-base-upper)
    ("=" smerge-diff-upper-lower)
    (">" smerge-diff-base-lower)
    ("R" smerge-refine)
    ("E" smerge-ediff)
    ("C" smerge-combine-with-next)
    ("r" smerge-resolve)
    ("k" smerge-kill-current)
    ("ZZ" (lambda ()
            (interactive)
            (save-buffer)
            (bury-buffer))
     "Save and bury buffer" :color blue)
    ("q" nil "cancel" :color blue))

  :general
  (
   :keymap 'launch-key
   "C-c ^ ^"'unpackaged/smerge-hydra/body
   )

  ;;:hook (
         ;;((diff-mode magit-status-mode magit-diff-mode git-commit-mode) . (lambda () (text-scale-set -2)))
         ;;)
  )




