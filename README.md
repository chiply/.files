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
- **Editor**: Emacs 31 (via `emacs-plus@31`) configured by [zetta.d](https://github.com/chiply/.zetta.d), with TeX Live (`dvipng` / `dvisvgm`) and MathJax for `org-latex-preview`. `install_emacs_distros.sh` can additionally install Doom / Spacemacs / Chemacs side-by-side, plus two extra Emacs builds — see [Emacs variants](#emacs-variants).
- **Languages**: pyenv (3.10 / 3.11 / 3.12), Poetry, uv, nvm + Node, language servers (json, eslint, copilot, svelte)
- **Misc CLI**: AWS CLI v2, `gh`, `k9s` (with catppuccin skins), `bat`, `fzf`, `ripgrep`, `eza`, `jq`, `lazygit`, and more — full list in [`files/.config/Brewfile`](files/.config/Brewfile)
- **Background services**: signal-cli daemon (opt-in via `$SIGNAL_PHONE`), a wallpaper rotator, and launchd-managed simple-bar refresh server + focus watcher

## Layout

```
.files/
├── bootstrap.sh              # main installer
├── main.py                   # symlinks files/* -> ~/*
├── install_emacs_distros.sh  # optional: install Doom/Spacemacs/Chemacs side-by-side
├── install_emacs_source.sh   # optional: build GNU Emacs master from source
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

## Emacs variants

Three Emacs builds can run side by side, each on its own
[chemacs](https://github.com/plexus/chemacs) profile so their package trees never
mix — elpaca's bytecode and `native-lisp` output are per-Emacs-version, and
sharing a config directory between versions corrupts both.

| Build | Version | App | Profile / config | Gate |
| --- | --- | --- | --- | --- |
| `emacs-plus@31` | 31.x | `/Applications/Emacs.app` | `zetta` → `~/.zetta.d` | always |
| [emacs-mac](https://github.com/jdtsmith/emacs-mac) | 30.x | `~/Applications/EmacsMac.app` | `zetta-mac` → `~/.zetta-mac.d` | `INCLUDE_EMACS_MAC` |
| from source | master (32.0.50) | `~/Applications/EmacsSrc.app` | `zetta-src` → `~/.zetta-src.d` | `INCLUDE_EMACS_SRC` |

The gates are exported from `files/.zshrc`; each also brings in its build
dependencies via a matching block in the Brewfile.

### From-source build

`install_emacs_source.sh` compiles the upstream git tree. It tracks `master`
because that is where the **canvas** feature landed (canvas is unconditional
there — no `--with-canvas` flag, no patch to apply).

It reproduces `emacs-plus@31`'s feature set deliberately, so the two are
interchangeable: the same configure flags, the same four NS patches from the
`d12frosted/emacs-plus` tap, and the same post-install work on the app bundle
(PATH injection, TCC usage descriptions, AutoFill opt-out, ad-hoc codesign).
That last group is load-bearing — without the TCC keys anything launched from
inside Emacs (`M-x shell`, `compile`, org-babel) is killed the moment it
touches a protected framework.

Unlike a Homebrew build it also has to pass `-I$(brew --prefix)/include`
explicitly, since Homebrew's `superenv` is what normally supplies that; without
it configure silently misses `gmp.h`, `gif_lib.h`, `jpeglib.h` and `tiff.h` and
produces an Emacs without GMP, GIF, JPEG or TIFF while reporting success.

```bash
./install_emacs_source.sh              # build the pinned revision (no-op if current)
./install_emacs_source.sh --bump       # move the pin to origin/master and rebuild
./install_emacs_source.sh --rebuild    # force a clean rebuild of the pinned revision
EMACS_SRC_REVISION=<sha> ./install_emacs_source.sh --rebuild   # roll back
```

The revision is pinned in `files/.config/emacs-src/revision` and moved forward
deliberately with `--bump` (aliased to `emacs-src-update`), so a fresh machine
reproduces the same Emacs and a bad master commit is one edit from a rollback.
AOT native compilation makes a build take 45–70 minutes; set
`EMACS_SRC_NATIVE_COMP=yes` for lazy compilation and a ~10 minute build.

Aliases: `emacs-src`, `emacs-src-daemon` / `ecs`, `emacs-src-update`,
`emacs-src-version`.

## Caveats

- macOS only. Developed on Apple Silicon; Intel should mostly work (`/opt/homebrew` and `/usr/local` are both on `PATH`) but isn't actively tested.
- `bootstrap.sh` is idempotent for most steps but isn't guaranteed safe to run on a heavily-customised existing machine — it will overwrite symlinks and dotfiles under `$HOME`.
- The Emacs config (`zetta.d`) lives in its own repo and has its own footprint (~270 package configurations, devdocs, tree-sitter binaries). If you only want the shell/tmux setup, comment out the emacs section near the bottom of `bootstrap.sh`.
- `fetch_mail.sh` and `files/.newsrc*` are gitignored — those are personal to me and aren't part of the published config.

## License

MIT — see [LICENSE](LICENSE).
