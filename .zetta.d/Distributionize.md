# Turning .zetta.d into an Emacs Distribution

A plan for transforming this personal Emacs configuration into a distributable Emacs framework, in the spirit of Spacemacs and Doom Emacs.

---

## Current Architecture Assessment

### Fully Distributable Components

| Component | Notes |
|---|---|
| `early-init.el` | Pure startup optimization, zero personal code |
| `bootstrap-elpaca.el` | Standard Elpaca package manager setup |
| `bootstrap-utils.el` | Just installs utility libraries (dash, s, f, ht, ts) |
| `bootstrap-keys.el` | Generic keybinding framework — excellent `launch-map` abstraction over evil/meow/emacs |
| `bootstrap-brushup.el` | Theme-aware parametric gradient system — fully parameterized, reusable |
| `bootstrap-evil.el` | Standard evil configuration |
| `repeatable-lite/` (zettapkg) | Well-designed repeatable keymap system |
| `space-tree/` (zettapkg) | Clean workspace management — MELPA-ready |
| `convention/` (zettapkg) | Docker container workflow, well-modularized |
| `gha/` (zettapkg) | GitHub Actions integration, generic workflow |
| `z-load-config-file()` | Generic file loading mechanism |

### Partially Distributable (Need Abstraction)

| Component | Issue |
|---|---|
| `init.el` | Logic is generic; hardcoded personal paths (bookmarks, tramp profiles) |
| `init-data.el` | List structure is sound; 276-entry list contents are personal |
| `bootstrap-display.el` | Framework (`z-side`) is generic; dimension configs are personal |
| `bootstrap-org.el` | Core setup generic; custom variables and paths mixed in |
| `bootstrap-zettafn.el` | Half utility library, half personal tools |
| `spot4e/` (zettapkg) | **Exposes hardcoded Spotify API credentials — must remove before any distribution** |

### Not Distributable (Personal)

- `~/.private.el` — API keys and secrets
- Most of `config/` — personal workflow configurations
- Bookmarks, elfeed subscriptions, forge database
- Tramp connection profiles

---

## Differentiators

These are the unique strengths that would define this distro's identity:

1. **brushup** — No other distro has parametric theme-aware color gradients. Packages register styles in `brushup-styles` and faces auto-update on theme change.
2. **repeatable-lite** — Unique repeatable prefix command system integrated with which-key.
3. **Triple-modal support** — Evil, Meow, and vanilla Emacs editing in one config, switchable with `s-z m/e/E`.

---

## Key Architectural Changes

### 1. Introduce a Module System

The flat `user-files` list in `init-data.el` (~276 entries) must become an opt-in module system. Group config files into modules:

```elisp
;; User's config file (~/.zetta.el):
(zetta-modules!
 :core        ; emacs.el, files.el, buffers.el — always loaded
 :completion  ; vertico, consult, orderless, corfu
 :ui          ; themes, modeline, treemacs, dashboard
 :editor      ; evil, snippets, multiple-cursors
 :lang        ; python, rust, go, javascript...
 :tools       ; magit, docker, lsp, dap
 :app         ; elfeed, spotify, mu4e
)
```

Each module is a directory containing `config.el` (package configurations) and optionally `packages.el` (declarations). Users enable/disable modules in a single init file rather than editing the distro's files.

**Implementation:** Write a `zetta-modules!` macro that:
- Accepts a keyword list of module categories
- Each category maps to a directory under `modules/`
- Loads `config.el` from each enabled module
- Replaces the current `user-files` list in `init-data.el`

### 2. Separate Framework from Opinion

Split into three tiers:

- **Core framework** (non-optional): early-init, Elpaca bootstrap, config loading, brushup, keybinding infrastructure
- **Default modules** (enabled by default, can be disabled): evil, vertico, magit, org, etc.
- **Optional modules** (disabled by default): spot4e, convention, elfeed, etc.

### 3. Abstract Personal Paths into a User Config File

Create a user-facing config entry point:

```elisp
;; ~/.zetta.el (or ~/.config/zetta/config.el)
(setq zetta-leader-key ","
      zetta-org-directory "~/org/"
      zetta-font "JetBrains Mono"
      zetta-theme 'modus-vivendi)

(zetta-modules!
 :lang (python rust go)
 :tools (magit docker lsp))
```

This replaces the current pattern of editing `init-data.el` directly. The distro's own files are never modified by users.

### 4. Create a CLI Installer

Like `doom install` or Crafted Emacs' setup:

```bash
git clone https://github.com/you/zetta ~/.zetta.d
~/.zetta.d/bin/zetta install   # install packages, build native comp
~/.zetta.d/bin/zetta sync      # after config changes
~/.zetta.d/bin/zetta doctor    # diagnose issues
~/.zetta.d/bin/zetta freeze    # write lockfile (see below)
```

---

## Reproducibility with Elpaca

### Lock File Support

Elpaca has functional (if minimal) lockfile support, already present in the installed version.

**Key pieces:**

- `elpaca-write-lock-file` — Interactive command that snapshots every queued package's exact commit SHA into an elisp alist file.
- `elpaca-lock-file` — Variable pointing to that file. When set, `elpaca-menu-lock-file` (already first in the default `elpaca-menu-functions` list) uses those exact commits when installing.

**Setup (add to bootstrap-elpaca.el):**

```elisp
(setq elpaca-lock-file
      (expand-file-name "elpaca-lock.el" user-emacs-directory))
```

**Workflow:**

1. Develop and test with latest packages.
2. When stable, run `M-x elpaca-write-lock-file` — commit the resulting `elpaca-lock.el` into the repo.
3. Users clone the distro and get the lockfile — Elpaca installs those exact versions.
4. Users who want bleeding edge can set `elpaca-lock-file` to `nil`.

Step 2 should be wrapped into the CLI: `bin/zetta freeze`.

### Per-Package Pinning

Three recipe keywords, all of which mark the package as "pinned" (skipped by `elpaca-fetch-all` / `elpaca-pull-all`):

```elisp
;; Pin to exact commit (highest precision):
(use-package some-pkg :ensure (:ref "a76ca0a"))

;; Pin to a git tag (release-level control):
(use-package some-pkg :ensure (:tag "v2.1"))

;; Freeze at whatever is currently installed:
(use-package some-pkg :ensure (:pin t))
```

### Comparison with straight.el

| | straight.el | elpaca |
|---|---|---|
| Freeze all versions | `straight-freeze-versions` | `M-x elpaca-write-lock-file` |
| Restore from lockfile | `straight-thaw-versions` | Set `elpaca-lock-file`, delete + restart |
| Lockfile format | elisp alist | elisp alist |
| Pin single package | `:pin` in recipe | `:ref`, `:tag`, or `:pin` in recipe |
| Single-command restore | Yes | **No** — weakest point |

### The Gap

The restore workflow is the rough edge. With straight.el you run `straight-thaw-versions` and you're done. With Elpaca, restoring means: delete affected packages, set `elpaca-lock-file`, restart Emacs. There is no single "thaw" command yet. This is functional but less polished.

---

## Implementation Steps (Ordered)

### Phase 1: Cleanup and Security

1. **Remove credentials** — `spot4e.el` has hardcoded Spotify client ID and secret. Move to `~/.private.el` or environment variables immediately.
2. **Audit for other personal data** — Tramp machine names in `init.el`, hardcoded bookmark paths, etc.

### Phase 2: Module System

3. **Create the module directory structure** — Group the 276 config files from `source/config/` into `modules/{core,ui,completion,editor,lang,tools,app}/` directories.
4. **Write the `zetta-modules!` macro** — Declarative module selection, replaces `user-files`.
5. **Create a user config template** — `~/.zetta.el` that users copy and customize.

### Phase 3: Reproducibility

6. **Enable Elpaca lockfile** — Set `elpaca-lock-file` in `bootstrap-elpaca.el`, generate initial lockfile, commit it.
7. **Pin known-fragile packages** — Use `:ref` or `:tag` for packages with frequent breaking changes.

### Phase 4: Packaging

8. **Extract standalone packages** — Publish `space-tree`, `repeatable-lite`, and `brushup` as independent packages (MELPA candidates). The distro depends on them, but they gain users independently.
9. **Write the CLI wrapper** — `bin/zetta` shell script for install, sync, update, freeze, doctor commands.

### Phase 5: Documentation

10. **Write a README** — Installation, module reference, quick start.
11. **Keybinding cheat sheet** — Auto-generated from `general.el` declarations if possible, otherwise manual.
12. **Module documentation** — Each module directory gets a brief header comment explaining what it provides.

---

## Managing Self-Authored Packages

Several packages in `source/zettapkg/` (space-tree, repeatable-lite, brushup, convention, gha, etc.) are original work worth publishing independently. This section covers how to structure them for both local development and public distribution.

### Separate Repos vs. Keeping zettapkg

**Separate repos is the right move for packages you want others to use.** Here's why:

- MELPA requires each package to live in its own Git repository.
- Independent repos get their own issue trackers, stars, CI, and versioning.
- Other users (including non-distro users) can install them standalone.
- Your distro declares them as dependencies rather than bundling them.

However, **not everything needs to be extracted.** Use this rule of thumb:

| Package | Extract? | Reason |
|---|---|---|
| `space-tree` | **Yes** | Novel, general-purpose, MELPA candidate |
| `repeatable-lite` | **Yes** | Useful standalone, clean API |
| `brushup` | **Yes** | Unique color system, any config can use it |
| `convention` | Maybe | Docker workflow — niche but self-contained |
| `gha` | Maybe | GitHub Actions — small, could be a gist or package |
| `spot` / `spot4e` | Maybe | Spotify integration — niche audience |
| `j`, `menu` | Probably not | Tightly coupled to distro internals |
| `foreman` | Probably not | Likely too specific |

**Recommended directory layout:**

```
~/source_code/
├── space-tree/           # standalone repo → github.com/you/space-tree
│   ├── space-tree.el
│   ├── README.md
│   ├── LICENSE
│   └── .github/          # CI for byte-compilation, testing
├── repeatable-lite/      # standalone repo
│   └── ...
└── brushup/              # standalone repo
    └── ...

~/.zetta.d/
└── source/zettapkg/
    ├── j/                # stays here — distro-internal
    ├── menu/             # stays here — distro-internal
    └── foreman/          # stays here — distro-internal
```

### Local Development vs. Public Distribution

The core problem: you want to hack on `space-tree` locally in `~/source_code/space-tree/` while your distro tells users to install it from GitHub. Elpaca handles this cleanly.

#### How It Works

**In your distro's module config (what users get):**

```elisp
;; modules/ui/config.el — public recipe, fetches from GitHub
(use-package space-tree
  :ensure (:host github :repo "you/space-tree"))
```

**In your personal `~/.zetta.el` (overrides the distro recipe):**

```elisp
;; Point to your local checkout for development
(use-package space-tree
  :ensure (:host github :repo "you/space-tree"
           :local-path "~/source_code/space-tree"))
```

Elpaca's `:local-path` recipe keyword tells it to symlink to your local directory instead of cloning from the remote. You edit files in `~/source_code/space-tree/`, changes take effect immediately (after `eval-buffer` or restart), and the remote repo is never touched until you push.

#### Alternative: :repo with a local file path

If `:local-path` is unavailable in your Elpaca version, you can use the `load-path` approach:

```elisp
;; In your personal ~/.zetta.el, before the distro loads:
(push "~/source_code/space-tree" load-path)

;; Then override the ensure to skip remote install:
(use-package space-tree
  :ensure nil)   ; don't fetch — already on load-path
```

This is simpler but less integrated with Elpaca's update machinery.

#### Workflow Summary

```
┌─────────────────────────────────────────────────────┐
│ Your machine (developer)                            │
│                                                     │
│  ~/source_code/space-tree/  ← you edit here         │
│         │                                           │
│         │ symlink or load-path                      │
│         ▼                                           │
│  ~/.zetta.d/ loads space-tree from local path       │
│         │                                           │
│         │ git push                                  │
│         ▼                                           │
│  github.com/you/space-tree  ← public repo           │
│                                                     │
├─────────────────────────────────────────────────────┤
│ User's machine                                      │
│                                                     │
│  ~/.zetta.d/ loads space-tree via Elpaca from       │
│  github.com/you/space-tree (pinned by lockfile)     │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### Publishing to MELPA

For packages you extract, the MELPA submission process:

1. Ensure the package has a proper header (`;;; space-tree.el --- ...`), `Version:`, `Package-Requires:`, and autoloads (`;;;###autoload`).
2. Add a `LICENSE` file (GPL-3.0 is standard for Emacs packages).
3. Submit a PR to [melpa/melpa](https://github.com/melpa/melpa) with a recipe file.
4. Once accepted, users can install via `M-x package-install` or any package manager.

Your distro can then reference the MELPA version, and Elpaca will fetch it from there — no `:host github` needed.

### Packages That Stay in zettapkg

For distro-internal packages that don't warrant their own repo, keep them in `source/zettapkg/` and load with `:ensure nil`:

```elisp
(use-package menu
  :ensure nil
  :demand t
  :load-path "source/zettapkg/menu")
```

These ship with the distro and are loaded directly from the tree. No separate install step for users.

---

## Reference: Distributions to Study

- **Doom Emacs** (`doomemacs/doomemacs`) — Best module system, CLI tooling, and lockfile approach. Study `lisp/doom-modules.el` and `lisp/doom-packages.el`.
- **Spacemacs** (`syl20bnr/spacemacs`) — Layer system is the original approach, but more complex. Study the "layer" concept.
- **Crafted Emacs** (`SystemCrafters/crafted-emacs`) — Simpler, more modern take. Good model for a lighter-weight distro.

---

## Naming

The current internal prefix is `z-` for functions and variables. For a distribution, consider whether to keep this or adopt a more distinctive namespace (e.g., `zetta-`). Consistency matters — pick one and use it everywhere.
