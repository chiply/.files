(
 ("default" . ((user-emacs-directory . "~/.zetta.d")))
 ("zetta" . ((user-emacs-directory . "~/.zetta.d")))
 ("spacemacs" . ((user-emacs-directory . "~/.spacemacs.d")))
 ("doom" . ((user-emacs-directory . "~/.doom.d")))
 ("prelude" . ((user-emacs-directory . "~/.prelude.d")))
 ("centaur" . ((user-emacs-directory . "~/.centaur.d")))
 ("tera" . ((user-emacs-directory . "~/source_code/.tera.d")))
 ;; Isolated clone of .zetta.d for the experimental emacs-mac (Emacs
 ;; 30) trial — its elpaca builds compile under 30.x, never mixing
 ;; with the 31-compiled bytecode in ~/.zetta.d (see the 2026-07
 ;; version-skew saga).  Created by install_emacs_distros.sh when
 ;; INCLUDE_EMACS_MAC=t.
 ("zetta-mac" . ((user-emacs-directory . "~/.zetta-mac.d")))

 ;; Emacs built from the upstream git tree (master, 32.0.50 -- the release
 ;; where canvas landed).  Isolated for the same reason as zetta-mac: elpaca
 ;; bytecode and native-lisp are per-Emacs-version, so 32 builds must never
 ;; mix with the 31-compiled tree in ~/.zetta.d.  Created by
 ;; install_emacs_distros.sh when INCLUDE_EMACS_SRC=t.
 ("zetta-src" . ((user-emacs-directory . "~/.zetta-src.d")))
 )
