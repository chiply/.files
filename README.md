# .files

Personal macOS dotfiles. Bootstraps a fresh machine with the tools, shell, terminal, window manager, and editor I use day-to-day, then symlinks every config in `files/` to the matching path under `$HOME`.

This repo is shared as a reference; clone, fork, or just lift bits that are useful. macOS only — Apple Silicon assumed (`/opt/homebrew` is on `PATH` first, with `/usr/local` as a fallback).

## Quick start

```bash
git clone https://github.com/chiply/.files.git ~/.files
cd ~/.files
./bootstrap.sh
```

The script asks for your `sudo` password upfront, then runs unattended for ~30 minutes. It will install Xcode CLI tools, Homebrew, and a long list of CLI utilities and language toolchains.

## What gets installed

- **Shell**: zsh + [zinit](https://github.com/zdharma-continuum/zinit) for plugins, [starship](https://starship.rs/) prompt, [atuin](https://atuin.sh/) for shared shell history
- **Terminal**: [Ghostty](https://ghostty.org/) with cursor shaders
- **Multiplexer**: tmux + [tmux-powerline](https://github.com/erikw/tmux-powerline), [tmuxinator](https://github.com/tmuxinator/tmuxinator), TPM and a curated plugin list
- **Window manager / status bar**: [AeroSpace](https://github.com/nikitabobko/AeroSpace), [simple-bar](https://www.jeantinland.com/toolbox/simple-bar/) (with a customised bottom bar), [borders](https://github.com/FelixKratz/JankyBorders)
- **Editor**: Emacs 31 (via `emacs-plus@31`) configured by [zetta.d](https://github.com/chiply/.zetta.d), plus an `install_emacs_distros.sh` that can also install Doom / Spacemacs side-by-side
- **Languages**: pyenv (3.10/3.11/3.12), Poetry, uv, nvm + Node, language servers (json, eslint, copilot, svelte)
- **Misc**: lots of CLI tools listed in [`files/.config/Brewfile`](files/.config/Brewfile) — bat, fzf, ripgrep, eza, jq, gh, k9s, lazygit, magit-friendly Git tooling, etc.
- **Background services**: signal-cli daemon, a wallpaper rotator, and a `pm2`-managed simple-bar focus watcher

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
- install LaunchAgents for `signal-cli` and the wallpaper rotator
- create `~/Wallpapers` and `~/Screenshots`
- run `defaults write` for Shottr screenshot preferences
- install simple-bar into `~/Library/Application Support/Übersicht/widgets/`

If any of that isn't what you want, read through `bootstrap.sh` (it's a single ~230-line script) and comment out the bits you'd rather skip before running.

## Customising

- **Packages**: edit `files/.config/Brewfile` and re-run `brew bundle --file=files/.config/Brewfile`
- **Shell**: `files/.zshrc` is the entry point; aliases live in `files/.aliases/`
- **Tmux**: `files/.tmux.conf`, themes under `files/.tmux/themes/`
- **Tmuxinator projects**: `files/.config/tmuxinator/*.yml`

## Adding a new dotfile

1. Drop the file under `files/` at the path you want it to live under `$HOME` (e.g. `files/.config/foo/bar.toml` → `~/.config/foo/bar.toml`).
2. Run `python ~/.files/main.py` to create the symlink.

## Caveats

- macOS only. The setup assumes Apple Silicon (`/opt/homebrew`); Intel users will hit a few hardcoded brew paths.
- `bootstrap.sh` is idempotent for most steps but isn't guaranteed safe to run on a heavily-customised existing machine — it will overwrite symlinks under `$HOME`.
- The Emacs config (`zetta.d`) lives in its own repo and has its own footprint (~270 package configurations, devdocs, tree-sitter binaries). If you only want the shell/tmux setup, comment out the emacs section near the bottom of `bootstrap.sh`.
- `fetch_mail.sh` and `files/.newsrc*` are gitignored — those are personal to me and aren't part of the published config.

## License

MIT — see [LICENSE](LICENSE).
