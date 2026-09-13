---
name: bare-demo
description: This skill should be used when the user wants to test an Emacs package in a bare "emacs -Q" to prove it has no coupling to their personal config — phrased as "bare emacs demo", "emacs -Q test file", "smoke test this package in a clean emacs", "make a demo init for this package", or when publishing/releasing an Emacs package and verifying it installs and configures cleanly from scratch. Generates demo/demo-init.el + demo/run.sh in the package repo.
version: 0.1.0
---

# Bare-Emacs Demo Generator

Scaffold a self-contained `demo/` in an Emacs package repo that installs and
configures the package in a stock `emacs -Q` — no personal config, no third-party
package manager. This catches accidental coupling (the package silently relying on
something only loaded in the author's config) and doubles as copy-pasteable user
documentation.

Two artifacts are produced per package:

- **`demo/demo-init.el`** — the clean, committed "no-BS" example: bootstrap
  `package.el`, install dependencies, load the package, configure it with a
  *pressable* demonstration. Honest enough that a user can copy from it.
- **`demo/run.sh`** — your repeatable launcher: a throwaway sandbox (real
  `~/.emacs.d` untouched) + a named server at a fixed socket so an LLM can
  eval into the live session, then `emacs -Q -l demo/demo-init.el`.

Requires **Emacs 30.1+** on the user's machine (built-in `use-package`, `:vc`
keyword, many former-ELPA packages now bundled). Confirm with `emacs --version`.

## Step 1 — Gather facts about the package

Work in the package's repo root. Identify the main file (`<pkg>.el`) and read:

```bash
PKG_DIR="${1:-$PWD}"; cd "$PKG_DIR"
MAIN=$(ls *.el | grep -vE -- '-(autoloads|pkg|test)\.el$' | head -1)
# Header: package name, URL, Package-Requires
sed -n '1,15p' "$MAIN" | grep -iE '^;;; |;; (URL|Version|Package-Requires)'
# Public API to build a real demo config from:
grep -nE ';;;###autoload|\(define-minor-mode |\(define-globalized-minor-mode |\(defun [a-z].*\binteractive\b|\(defcustom |\(defvar.*-map\b|\(defmacro ' "$MAIN"
# Read the Commentary block — it usually contains the intended usage example.
sed -n '/^;;; Commentary:/,/^;;; Code:/p' "$MAIN"
```

Note: package name, GitHub URL (the `;; URL:` header), the `Package-Requires`
list, the main entry point(s) (a mode to enable, key commands to bind), and any
macro the user is meant to wrap commands with.

## Step 2 — Classify each dependency

From `Package-Requires`, ignore the `(emacs "X.Y")` entry (that's just the min
version — record it as the README requirement). For every *other* dependency,
decide how it gets installed by probing a bare Emacs:

```bash
emacs -Q --batch --eval '(princ (if (locate-library "DEP") "BUILTIN" "ABSENT"))'
```

- **BUILTIN** (e.g. `which-key`, `seq`, `project`, `use-package`, `eglot` on
  Emacs 30.1+): nothing to install. Add a one-line comment in demo-init noting it
  ships with Emacs — that fact is itself part of the no-coupling story.
- **ABSENT + on an archive** (most third-party deps, e.g. `embark`, `magit`,
  `consult`): emit a `use-package DEP :ensure t` form *before* the package form.
- **ABSENT + GitHub-only** (typically a sibling package of the author's, not on
  MELPA — check the dep's own `;; URL:` header or ask the user): emit
  `use-package DEP :vc (:url "https://github.com/USER/DEP" :rev :newest)` before
  the package form.

Dependency forms MUST appear before the package-under-test form so they are on
`load-path` when it `require`s them.

## Step 3 — Write `demo/demo-init.el`

Use the template below. Fill placeholders: `<PKG>` (feature/package name),
`<PKG-URL>` (GitHub URL from header), `<DEP-FORMS>` (forms from Step 2, or a
comment if none), and `<CONFIG-BODY>` (Step 4). Keep the local-vs-published toggle.

```elisp
;;; demo-init.el --- Bare-Emacs install + config demo for <PKG> -*- lexical-binding: t; -*-

;; Canonical, no-BS example of installing and configuring <PKG> in a stock Emacs
;; (>= <MIN-VERSION>) with ZERO dependency on any personal configuration.
;;
;;   1. Plain:     emacs -Q -l demo/demo-init.el
;;   2. Sandboxed: ./demo/run.sh        (throwaway ~/.emacs.d + live-eval server)
;;
;; End-user one-liner for their own init:
;;     (use-package <PKG>
;;       :vc (:url "<PKG-URL>" :rev :newest)
;;       :config <...>)

;;; Code:

;; t   -> load THIS working-tree checkout (test local changes; edits are live)
;; nil -> install the PUBLISHED package from GitHub (reproduce the end-user path)
(defvar demo-install-from-local t)

(require 'package)
(setq package-archives
      '(("gnu"    . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")
        ("melpa"  . "https://melpa.org/packages/")))
(package-initialize)
(require 'use-package)
(setq use-package-always-ensure nil)

;; --- Dependencies ---
<DEP-FORMS>

;; --- The package under test ---
(if demo-install-from-local
    (progn
      (add-to-list 'load-path
                   (directory-file-name
                    (file-name-directory
                     (directory-file-name
                      (file-name-directory (or load-file-name buffer-file-name))))))
      (use-package <PKG> :demand t))
  (use-package <PKG>
    :vc (:url "<PKG-URL>" :rev :newest)
    :demand t))

;; --- Configure it: a real, pressable demonstration ---
(with-eval-after-load '<PKG>
  <CONFIG-BODY>)

(provide 'demo-init)
;;; demo-init.el ends here
```

Notes on the template:
- `:load-path` as a use-package keyword only accepts a *literal* string; do NOT
  pass it a computed form (it gets misread as a variable). Compute the repo root
  with plain elisp and `add-to-list` instead, as above.
- Put config in `with-eval-after-load` (not `:config`) so it is written once and
  works for both branches of the toggle. Any author macros (e.g. a `-wrap` macro)
  are available there because the feature is already loaded.

If a dependency is archive-based, `<DEP-FORMS>` looks like:
`(use-package embark :ensure t)`. If GitHub-only:
`(use-package treesit-tap :vc (:url "https://github.com/USER/treesit-tap" :rev :newest) :demand t)`.
If there are none, write a comment, e.g.
`;; No external dependencies — which-key is built into Emacs 30.1+.`

## Step 4 — Write a *pressable* `<CONFIG-BODY>`

The demo must let the user actually feel the feature with no typing of their own.
Build it from the package's public API (Step 1), using ONLY built-in Emacs
facilities for scaffolding (`define-prefix-command`, `keymap-set`, `define-key`,
`global-set-key`) — never general.el, evil, hydra, etc.

Patterns:
- Package provides a (global) minor mode → enable it: `(<pkg>-mode 1)`.
- Package provides interactive commands → bind a representative one or two to keys
  and tell the user the binding.
- Package provides a "wrap this command" macro → set up a small real example
  (e.g. a `C-c w` windmove prefix) demonstrating the effect.
- ALWAYS end with a `(message "...")` stating exactly what to press/try.

Example (for repeatable-lite, whose `repeatable-lite-wrap` macro makes a prefix
keymap sticky):

```elisp
(repeatable-lite-mode 1)
(define-prefix-command 'demo-window-map)
(keymap-set global-map "C-c w" 'demo-window-map)
(keymap-set demo-window-map "h" (repeatable-lite-wrap windmove-left))
(keymap-set demo-window-map "l" (repeatable-lite-wrap windmove-right))
(message "Try: C-x 3 to split, then C-c w h / l and keep tapping h/l.")
```

## Step 5 — Write `demo/run.sh`

Copy this verbatim (it is package-agnostic). `chmod +x demo/run.sh` after.

```bash
#!/usr/bin/env bash
# Launch <PKG> in a sandboxed bare Emacs (emacs -Q) with a live-eval server,
# loading demo/demo-init.el. Nothing here touches your real ~/.emacs.d.
#
#   ./demo/run.sh            # GUI session
#   ./demo/run.sh -nw        # terminal session (extra args pass through to emacs)
#
# Eval into THIS session (no $TMPDIR hunting — the socket path is fixed):
#   emacsclient -s "$(cat demo/.server-socket)" -e '(load-file "/abs/path/<PKG>.el")'
#
# Reset the sandbox (force clean reinstall):  rm -rf demo/.sandbox
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SANDBOX="$HERE/.sandbox"
SOCKET="$SANDBOX/server"
mkdir -p "$SANDBOX"
chmod 700 "$SANDBOX"   # Emacs refuses a server socket in a group/other-accessible dir
printf '%s\n' "$SOCKET" > "$HERE/.server-socket"
echo "sandbox : $SANDBOX   (rm -rf to reset)"
echo "server  : emacsclient -s \"$SOCKET\" -e '(...)'"
# Load the demo BEFORE starting the server: an --eval that errors aborts the rest
# of the command line, so the server must come last or it could shadow the demo.
exec emacs -Q \
  --eval "(setq user-emacs-directory \"$SANDBOX/\" package-user-dir \"$SANDBOX/elpa/\")" \
  -l "$HERE/demo-init.el" \
  --eval "(progn (require 'server) (setq server-name \"$SOCKET\") (server-start))" \
  "$@"
```

## Step 6 — `.gitignore`

Ensure the repo's `.gitignore` contains (append if missing):

```
demo/.sandbox/
demo/.server-socket
```

`demo/demo-init.el` and `demo/run.sh` ARE committed; the sandbox and socket
pointer are not.

## Step 7 — Verify before declaring done

Run the demo non-interactively in a throwaway sandbox and confirm the package
loads, the mode/config applied, and no error printed:

```bash
cd "$PKG_DIR"; rm -rf demo/.sandbox; SB="$PWD/demo/.sandbox"; mkdir -p "$SB"
emacs -Q --batch \
  --eval "(setq user-emacs-directory \"$SB/\" package-user-dir \"$SB/elpa/\")" \
  -l demo/demo-init.el \
  --eval '(message "VERIFY loaded=%s" (featurep (quote <PKG>)))' 2>&1 \
  | grep -E "VERIFY|Error|error"
rm -rf demo/.sandbox demo/.server-socket
```

`loaded=t` with no `Error` lines = clean. If a dependency only available in the
user's config was being relied on implicitly, this is where it surfaces as a
`require`/void-function error — report it as a coupling bug to fix in the package.

## Step 8 — Live editing the running session (optional)

When the user has launched `./demo/run.sh`, an LLM can reload edited source live
against that specific session (independent of the user's main daemon) via the
fixed socket — this composes with the `emacs-eval` skill but targets `-s`:

```bash
SOCK=$(cat demo/.server-socket)
emacsclient -s "$SOCK" -e '(load-file "/abs/path/<PKG>.el")'   # reload after edit
emacsclient -s "$SOCK" -e '(<pkg>-some-command)'               # drive it
```

## Don't

- Don't use the obsolete `package-vc-install-from-checkout` (deprecated in Emacs
  31.1; its `:vc-dir` redirection does not reliably land on `load-path`). Use the
  `add-to-list 'load-path` + `:demand t` pattern for the local package.
- Don't reference general.el, evil, hydra, or any of the author's personal config
  in the demo — that defeats the entire purpose.
- Don't put `(server-start)` in `demo-init.el`; it belongs in `run.sh` so the
  committed example stays a pure install/config reference.
