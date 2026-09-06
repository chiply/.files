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

Since 2026-09-06 `~/.zetta.d` is compiled by the **source build**, which is
the daily driver. The isolated `zetta-src` profile existed only for the
side-by-side trial and was retired once the migration landed. The
consequence to remember: running `emacs-plus-31 --zetta` now loads Emacs-32
bytecode into Emacs 31. If you switch a tree between builds, re-run
`zetta install` under the Emacs you intend to use.

| Build | Version | App | Profile / config | Gate |
| --- | --- | --- | --- | --- |
| `emacs-plus@31` | 31.x | `/Applications/Emacs.app` | (see caveat below) | always |
| [emacs-mac](https://github.com/jdtsmith/emacs-mac) | 30.x | `~/Applications/EmacsMac.app` | `zetta-mac` → `~/.zetta-mac.d` | `INCLUDE_EMACS_MAC` |
| from source | master (32.0.50) | `~/Applications/EmacsSrc.app` | `zetta` → `~/.zetta.d` (**daily driver**) | `INCLUDE_EMACS_SRC` |

The gates are exported from `files/.zshrc`; each also brings in its build
dependencies via a matching block in the Brewfile.

### Launching: zemacs

chemacs answers *which config*; nothing answered *which Emacs*. With several
vendors installed side by side, that meant a hand-written alias per
build/profile pair, going stale on every upgrade. `files/bin/zemacs` is the
layer above chemacs, and it **discovers** builds rather than listing them — so
installing `emacs-plus@32` or bumping the source build makes a new command
appear without editing anything.

```bash
emacs-src-latest --zetta         # newest source build, ~/.zetta.d
emacs-plus-31 --zetta-mac -nw    # a specific build, in the terminal
emacs-src-latest --zetta --daemon
zemacs list                      # what is installed, and which profiles exist
zemacs shims                     # regenerate the ~/bin/emacs-* commands
```

Commands are `emacs-<vendor>-<version>` plus a `-latest` alias per vendor
(`emacs-src-latest`, `emacs-plus-latest`, `emacs-mac-latest`, and a bare
`emacs-latest`). A `--<name>` matching a profile in `~/.emacs-profiles.el`
becomes `--with-profile <name>`; everything else passes to Emacs untouched.

These are **shims in `~/bin`, not shell aliases**, so they work from scripts,
tmuxinator, AeroSpace and Alfred — not only in an interactive zsh. They are
generated (the set depends on what is installed), marked with a header comment
so regeneration only ever removes zemacs' own files, and rebuilt by
`bootstrap.sh`. `ZEMACS_DRY_RUN=1` prints the command instead of running it.

A bare `--daemon` gets the **vendor** as its socket name, not the build id, so
`emacsclient -s src` keeps working after the source build moves 32 → 33.
`zemacs client <build>` connects to the right one.

Build discovery is cached in `~/.local/state/zemacs/builds.tsv` (probing a
version means running each Emacs) and invalidates itself when a binary's mtime
moves — which a bumped source build does, since it replaces its bundle.

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
./install_emacs_source.sh --rollback   # swap in the previous bundle (seconds)
EMACS_SRC_REVISION=<sha> ./install_emacs_source.sh --rebuild   # any older revision
```

`--rollback` matters because master is a moving target. Each build keeps the
one it replaces as `EmacsSrc.app.prev`, so backing out a bad bump is a `mv`
rather than another 45–70 minutes. It is a *swap*, not a discard — run it twice
and you are back where you started, which makes it usable for A/B-ing a suspect
revision. The pin moves with the bundle, so the next plain run doesn't
helpfully rebuild the Emacs you just backed out of; commit
`files/.config/emacs-src/revision` to make the rollback stick.

Only one generation is kept (~400 MB). Anything older is a rebuild from the
source tree via `EMACS_SRC_REVISION`.

The revision is pinned in `files/.config/emacs-src/revision` and moved forward
deliberately with `--bump` (aliased to `emacs-src-update`), so a fresh machine
reproduces the same Emacs and a bad master commit is one edit from a rollback.
AOT native compilation makes a build take 45–70 minutes; set
`EMACS_SRC_NATIVE_COMP=yes` for lazy compilation and a ~10 minute build.

### Running it

chemacs picks the config; the app bundle picks the binary. `~/.emacs` is
chemacs, and nothing else competes for it (there is no `~/.emacs.el`,
`~/.config/emacs` or `~/.emacs.d/init.el`), so every Emacs on the machine goes
through it.

```bash
emacs-src                 # GUI, profile zetta
emacs-src-daemon          # daemon on its own socket ("src")
ecs                       # emacsclient -s src
ecs -nw                   # ... in the terminal
```

Or without the aliases, which is the same thing spelled out:

```bash
open -a ~/Applications/EmacsSrc.app --args --with-profile zetta
~/Applications/EmacsSrc.app/Contents/MacOS/Emacs --with-profile zetta
```

The socket name keeps `ecs` and the emacs-plus `emacsclient` from ever reaching
the same daemon.

**Do the package install first, headlessly.** zetta.d ships a `bin/zetta` CLI
that installs packages, byte-compiles `modules/` and native-compiles
`elpaca/builds/` in batch mode — don't leave that to the first GUI launch,
where it happens behind a frame with no progress reporting:

```bash
cd ~/.zetta.d
EMACS=~/Applications/EmacsSrc.app/Contents/MacOS/Emacs bin/zetta install
EMACS=~/Applications/EmacsSrc.app/Contents/MacOS/Emacs bin/zetta test    # daemon smoke test
EMACS=~/Applications/EmacsSrc.app/Contents/MacOS/Emacs bin/zetta doctor
```

`bin/zetta` takes the binary from `$EMACS` and derives its target directory
from its own location, so running the copy in `~/.zetta.d` builds that
tree. It passes `--init-directory` rather than going through chemacs —
`--with-profile` matters only for the interactive launches above.

Note `zetta install` purges `eln-cache/` first. That is deliberate and matters
more here than elsewhere: Emacs prefers a matching `.eln` over the `.elc` on
disk, so a stale native-compiled file from a different Emacs version silently
shadows the correct one. `zetta test` runs on a PID-suffixed daemon
(`zetta-test-$$`), so it never collides with the main one.

Aliases: `emacs-src`, `emacs-src-daemon` / `ecs`, `emacs-src-update`,
`emacs-src-rollback`, `emacs-src-version`.

## Caveats

- macOS only. Developed on Apple Silicon; Intel should mostly work (`/opt/homebrew` and `/usr/local` are both on `PATH`) but isn't actively tested.
- `bootstrap.sh` is idempotent for most steps but isn't guaranteed safe to run on a heavily-customised existing machine — it will overwrite symlinks and dotfiles under `$HOME`.
- The Emacs config (`zetta.d`) lives in its own repo and has its own footprint (~270 package configurations, devdocs, tree-sitter binaries). If you only want the shell/tmux setup, comment out the emacs section near the bottom of `bootstrap.sh`.
- `fetch_mail.sh` and `files/.newsrc*` are gitignored — those are personal to me and aren't part of the published config.

## License

MIT — see [LICENSE](LICENSE).
