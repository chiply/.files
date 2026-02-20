# .files Repository

Personal dotfiles repository for bootstrapping macOS development environments.

## Repository Structure

```
.files/
├── bootstrap.sh              # Main setup script for new machines
├── main.py                   # Symlink generation script
├── install_emacs_distros.sh  # Emacs installation script
├── files/                    # Dotfiles to be symlinked to ~/
│   ├── .zshrc                # Primary shell configuration
│   ├── .aliases/             # Shell aliases
│   ├── .config/              # Tool configurations (Brewfile, tmuxinator, etc.)
│   └── .tmux/, .tmux.conf    # Tmux configuration
```

### Other Directories

- `mcp_servers/` - MCP server configurations
- `.github/` - GitHub workflows

## Bootstrap Process

Run `bootstrap.sh` on a new machine to:
1. Install Xcode CLI tools, Homebrew
2. Install Python (3.10, 3.11, 3.12) via pyenv
3. Install Poetry and uv
4. Symlink dotfiles from `files/` to `~/`
5. Install Zinit (zsh plugin manager)
6. Install tools (fzf, AWS CLI, tmuxinator)
7. Install Emacs and language servers
8. Clone zetta.d Emacs distribution to `~/.zetta.d`

---

## Emacs Configuration (.zetta.d)

The Emacs configuration is a separate repository ([zetta.d](https://github.com/chiply/.zetta.d)) cloned to `~/.zetta.d/`. It uses **Elpaca** as the package manager.

### Directory Structure

```
.zetta.d/
├── init.el                   # Main entry point
├── early-init.el             # Early initialization (disables package.el)
├── source/
│   ├── bootstrap/            # Core initialization modules
│   ├── config/               # Package configuration files (~270 files)
│   ├── init-data/            # Defines list of configs to load
│   ├── extension/            # Custom extensions (e.g., dired/)
│   ├── lib/                  # External libraries
│   └── zettapkg/             # Custom packages (see below)
├── elpaca/                   # Package manager cache (builds/, repos/)
├── devdocs/                  # Developer documentation (22+ languages)
├── tree-sitter/              # Tree-sitter binaries
├── snippets/                 # Code snippets
└── prompts/                  # AI prompts
```

### Initialization Flow

1. **early-init.el** - Disables built-in package.el
2. **init.el** loads:
   - `init-data.el` - Defines `user-files` list of configs to load
   - `bootstrap.el` - Core modules (see below)
   - `~/.private.el` - Private API keys and credentials
   - Each file in `user-files` via `zetta-load-config-file`
3. **bootstrap.el** requires (in order):
   - `bootstrap-elpaca` - Elpaca package manager setup
   - `bootstrap-utils` - Utility functions
   - `bootstrap-keys` - Keybinding infrastructure (general.el, which-key)
   - `bootstrap-repeatable-lite` - Repeatable command utilities
   - `bootstrap-brushup` - Color/theme utilities
   - `bootstrap-display` - Display settings
   - `bootstrap-evil` - Evil mode (vi emulation)
   - `bootstrap-org` - Org-mode setup
   - `bootstrap-zettafn` - Custom loading functions

### Adding a New Package Configuration

1. Create a new `.el` file in `source/config/` (e.g., `my-package.el`)
2. Add the filename to the `user-files` list in `source/init-data/init-data.el`
3. Use `use-package` with `:ensure t` (default via `elpaca-use-package-mode`)

### Custom Packages (zettapkg/)

Custom packages in `source/zettapkg/`:

| Package            | Purpose                               |
|--------------------|---------------------------------------|
| `convention/`      | Docker container workflow utilities   |
| `foreman/`         | Process management integration        |
| `gha/`             | GitHub Actions helpers                |
| `menu/`            | Custom menu system                    |
| `repeatable-lite/` | Repeatable command framework          |
| `space-tree/`      | Workspace/space tree management       |
| `spot/`            | Spotify integration (consult, embark) |
| `spot4e/`          | Alternative Spotify integration       |
| `j/`               | Jump/navigation utilities             |

### Keybinding System

The config supports multiple modal editing systems (Evil, Meow, Emacs).

**Key concepts:**
- **`launch-map`** - Prefix command bound to `,` in non-insert states
- **`general.el`** - Used for all keybinding declarations
- **`which-key`** - Provides key hints (triggered by `C-h`)
- **Modal switching**: `s-z m` (Meow), `s-z e` (Evil), `s-z E` (Emacs)

**Common prefix maps** (accessible via `,` then key):
- `g` - Version control (magit)
- `p` - Project operations
- `w` - Window management
- `l` - Lookup/search
- `o` - Org-mode
- `r` - Run/compile
- `t` - Themes
- `h` - Help

**Package management shortcuts:**
- `s-u` - Fetch all packages (`elpaca-fetch-all`)
- `s-U` - Pull all packages (`elpaca-pull-all`)

---

## AI Guidance

### Elisp Conventions

**Use-package pattern** - All package configurations follow this structure:
```elisp
(use-package package-name
  :ensure t        ; (default, can omit)
  :demand t        ; Load immediately (not deferred)
  :after other-pkg ; Load after dependency
  :init            ; Code run before package loads
  :config          ; Code run after package loads
  :hook            ; Mode hooks
  :general         ; Keybindings via general.el
  :bind            ; Standard keybindings
  )
```

**Keybinding pattern** - Use `general-define-key`:
```elisp
(general-define-key
 :keymaps 'launch-map  ; Or specific mode-map
 "key" 'command)
```

**Naming conventions:**
- Custom functions: prefix with `zetta-` (e.g., `zetta-find-poetry-project-root`)
- Custom variables: prefix with `zetta-` (e.g., `zetta-pyvenv-virtual-env`)

### Common Gotchas

1. **Package loading order**: If a package depends on another, use `:after` or ensure the dependency is listed first in `user-files`

2. **Elpaca queues**: The config uses `(setq elpaca-queue-limit 8)` to limit concurrent package operations

3. **Private config**: API keys and secrets go in `~/.private.el` (not in repo)

4. **Evil mode conflicts**: Some packages need their keymaps unbound from Evil states; use `general-unbind`

5. **Tree-sitter modes**: Python uses `python-ts-mode` (not `python-mode`), JavaScript similar

6. **Config file loading**: Files can be commented out in `user-files` by prefixing with `;;`

### Key Files for Reference

| File                  | Purpose                                 |
|-----------------------|-----------------------------------------|
| `init-data.el`        | Master list of all config files to load |
| `bootstrap-keys.el`   | Keybinding infrastructure               |
| `bootstrap-elpaca.el` | Package manager configuration           |
| `emacs.el`            | Core Emacs settings                     |
| `evil.el`             | Evil mode configuration                 |
| `magit.el`            | Git integration                         |
| `python.el`           | Python development setup                |
| `lsp.el`              | Language Server Protocol configuration  |

### Testing Changes

**IMPORTANT: Always verify Emacs config changes before considering them complete.**

#### Automated Testing (Required)

After making changes to any `.el` files in `~/.zetta.d/`, run the daemon test:

```bash
# Start Emacs daemon and capture output
emacs --daemon=test-config 2>&1 | tee /tmp/emacs-test.log

# Check if daemon started successfully
emacsclient -s test-config -e '(message "Config OK")' 2>&1

# Clean up
emacsclient -s test-config -e '(kill-emacs)' 2>/dev/null

# Check for errors in log
grep -iE "error|wrong-type|void-function|did not start" /tmp/emacs-test.log
```

**Success criteria:**
- Daemon outputs "Starting Emacs daemon."
- `emacsclient` returns "Config OK"
- No error matches in log (ignore yasnippet snippet warnings)

**Failure indicators:**
- "Error: server did not start correctly"
- "wrong-type-argument"
- "void-function"
- Any Lisp error in stack trace

#### Quick Test Commands

```bash
# One-liner test (returns exit code 0 on success)
emacs --daemon=t 2>&1 | grep -q "Starting Emacs daemon" && \
  emacsclient -s t -e '(kill-emacs)' && echo "SUCCESS" || echo "FAILED"

# Batch mode test (faster, no daemon cleanup needed)
emacs --batch -l ~/.zetta.d/init.el 2>&1 | tail -5
```

#### Manual Testing

- `M-x eval-buffer` to test config file changes in isolation
- `M-x elpaca-fetch-all` then `M-x elpaca-pull-all` to update packages

#### Common Test Failures

| Error | Likely Cause |
|-------|--------------|
| `wrong-type-argument stringp nil` | Face color accessed before theme loads |
| `void-function` | Package not loaded, missing `:after` |
| `Symbol's value as variable is void` | Variable used before definition |

### Updating CLAUDE.md
When making salient changes to patterns, conventions, structure, or anything that would be important for AI guidance, please update this CLAUDE.md file accordingly.
