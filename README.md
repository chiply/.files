# .files

[![Bootstrap](https://github.com/chiply/.files/actions/workflows/test_install.yml/badge.svg)](https://github.com/chiply/.files/actions/workflows/test_install.yml)

Personal macOS dotfiles. Bootstraps a fresh machine with the tools, shell, terminal, window manager, and editor I use day-to-day, then symlinks every config in `files/` to the matching path under `$HOME`.

This repo is shared as a reference; clone, fork, or just lift bits that are useful. macOS only.

> ⚠️ **`bootstrap.sh` will silently replace any existing dotfiles in `$HOME`** (`.zshrc`, `.tmux.conf`, `.bash_profile`, …) with symlinks into this repo. If you already have configs you care about, back them up before running.

## Quick start

```bash
git clone https://github.com/chiply/.files.git ~/.files
cd ~/.files

# optional: set this if you want the signal-cli LaunchAgent installed.
# without it, the signal-cli block is skipped silently.
export SIGNAL_PHONE="+15551234567"

./bootstrap.sh
```

The script asks for your `sudo` password upfront, then runs unattended for ~30 minutes. It installs Xcode CLI tools, Homebrew, and a long list of CLI utilities and language toolchains.

## What gets installed

- **Shell**: zsh + [zinit](https://github.com/zdharma-continuum/zinit) for plugins, [starship](https://starship.rs/) prompt, [atuin](https://atuin.sh/) for shared shell history
- **Terminal**: [Ghostty](https://ghostty.org/) with cursor shaders, plus Nerd Fonts (JetBrains Mono Nerd Font, Terminess, Terminus)
- **Multiplexer**: tmux + [tmux-powerline](https://github.com/erikw/tmux-powerline), [tmuxinator](https://github.com/tmuxinator/tmuxinator), TPM (Tmux Plugin Manager) and a curated plugin list
- **Window manager / status bar**: [AeroSpace](https://github.com/nikitabobko/AeroSpace), [simple-bar](https://www.jeantinland.com/toolbox/simple-bar/) (with a customised bottom bar), [JankyBorders](https://github.com/FelixKratz/JankyBorders)
- **Editor**: Emacs 31 (via `emacs-plus@31`) configured by [zetta.d](https://github.com/chiply/.zetta.d), with TeX Live (`dvipng` / `dvisvgm`) and MathJax for `org-latex-preview`. `install_emacs_distros.sh` can additionally install Doom / Spacemacs / Chemacs side-by-side.
- **Languages**: pyenv (3.10 / 3.11 / 3.12), Poetry, uv, nvm + Node, language servers (json, eslint, copilot, svelte)
- **Misc CLI**: AWS CLI v2, `gh`, `k9s` (with catppuccin skins), `bat`, `fzf`, `ripgrep`, `eza`, `jq`, `lazygit`, and more — full list in [`files/.config/Brewfile`](files/.config/Brewfile)
- **Background services**: signal-cli daemon (opt-in via `$SIGNAL_PHONE`), a wallpaper rotator, and launchd-managed simple-bar refresh server + focus watcher

## Layout

```
.files/
├── bootstrap.sh              # main installer
├── main.py                   # symlinks files/* -> ~/*
├── install_emacs_distros.sh  # optional: install Doom/Spacemacs/Chemacs side-by-side
├── files/                    # everything in here is symlinked to $HOME
│   ├── .zshrc, .tmux.conf, .aerospace.toml, ...
│   └── .config/Brewfile      # full package list
├── ghostty/config            # symlinked separately into Application Support
└── LICENSE
```

`main.py` walks `files/` and creates `ln -s -f` symlinks at the matching paths under `$HOME`. Re-run it any time you add a new dotfile.

## Bootstrap side-effects

`bootstrap.sh` will:

- create `~/.localsecrets`, `~/.tokens`, and (via the Emacs config) expect `~/.private.el` — these hold local secrets and are never committed
- clone [`zetta.d`](https://github.com/chiply/.zetta.d) to `~/.zetta.d` for the Emacs setup
- install LaunchAgents for `signal-cli`, the wallpaper rotator, `simple-bar-server`, and the simple-bar focus watcher
- create `~/Wallpapers` and `~/Screenshots`
- run `defaults write` for Shottr screenshot preferences
- install simple-bar into `~/Library/Application Support/Übersicht/widgets/`

If any of that isn't what you want, read through `bootstrap.sh` (it's a single linear script) and comment out the bits you'd rather skip before running.

## Customising

- **Packages**: edit `files/.config/Brewfile` and re-run `brew bundle --file=files/.config/Brewfile`
- **Shell**: `files/.zshrc` is the entry point; aliases live in `files/.aliases/`
- **Tmux**: `files/.tmux.conf`, themes under `files/.tmux/themes/`. Notes on the setup are in [TMUX.md](TMUX.md).
- **Tmuxinator projects**: `files/.config/tmuxinator/*.yml`

### Forking

If you fork this repo, the parts you'll most likely want to change before running:

- The `git clone https://github.com/chiply/.zetta.d.git` line in `bootstrap.sh` — that's *my* Emacs configuration. Point it at your own, or comment out the entire emacs section if you don't want Emacs.
- The Quick start clone URL above.
- Tmuxinator project files under `files/.config/tmuxinator/` reference my project paths.

## Updating

After the initial bootstrap, to pull in new dotfiles or package additions:

```bash
cd ~/.files
git pull
python main.py                                      # re-symlink anything new
brew bundle --file=files/.config/Brewfile           # install new brews
```

## Adding a new dotfile

1. Drop the file under `files/` at the path you want it to live under `$HOME` (e.g. `files/.config/foo/bar.toml` → `~/.config/foo/bar.toml`).
2. Run `python ~/.files/main.py` to create the symlink.

## Caveats

- macOS only. Developed on Apple Silicon; Intel should mostly work (`/opt/homebrew` and `/usr/local` are both on `PATH`) but isn't actively tested.
- `bootstrap.sh` is idempotent for most steps but isn't guaranteed safe to run on a heavily-customised existing machine — it will overwrite symlinks and dotfiles under `$HOME`.
- The Emacs config (`zetta.d`) lives in its own repo and has its own footprint (~270 package configurations, devdocs, tree-sitter binaries). If you only want the shell/tmux setup, comment out the emacs section near the bottom of `bootstrap.sh`.
- `fetch_mail.sh` and `files/.newsrc*` are gitignored — those are personal to me and aren't part of the published config.

## License

MIT — see [LICENSE](LICENSE).
