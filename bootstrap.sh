#!/bin/bash

# resolve the directory containing this script so the repo can live anywhere
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Profile: `personal' (default) or `work' (an employer-managed machine).
# Set DOTFILES_PROFILE in ~/.zshenv.local, or pass --profile work here;
# the value is exported for main.py and the Brewfile, and `personal'
# gates every block below that pairs the machine with personal accounts
# or infrastructure (README.md, "Profiles"; work-profile.org Part 6.4).
DOTFILES_PROFILE="${DOTFILES_PROFILE:-personal}"
if [ "${1:-}" = "--profile" ]; then export DOTFILES_PROFILE="${2:?--profile needs a value}"; shift 2; fi
export DOTFILES_PROFILE
personal() { [ "$DOTFILES_PROFILE" != work ]; }
echo "bootstrap: profile $DOTFILES_PROFILE"

# This script is deliberately not `set -e': many steps may fail harmlessly
# on a given machine.  The steps that matter record their failure here
# and the script exits 1 at the end, so CI and setup-work-machine.sh see
# it (until 2026-09-14 a failed brew bundle or Emacs build passed CI).
BOOTSTRAP_FAILED=()
critical() { echo "bootstrap: CRITICAL STEP FAILED: $*" >&2; BOOTSTRAP_FAILED+=("$*"); }

# Prompt for sudo password upfront and keep alive
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

mkdir -p ~/.tmux/themes
mkdir -p ~/.config/tmux-powerline/themes
mkdir -p ~/.config/tmux-powerline/segments
mkdir -p ~/.config/gitmux
mkdir -p "$HOME/Library/Application Support/com.mitchellh.ghostty"

# macos thing - skip if already installed
if ! xcode-select -p &>/dev/null; then
    xcode-select --install
    # Wait for installation to complete
    until xcode-select -p &>/dev/null; do
        sleep 5
    done
fi

# install brew (non-interactive), then put it on THIS shell's PATH: on a fresh
# machine nothing has done that yet, and every brew line below would fail with
# "command not found" (measured on the first work-machine run, 2026-09-14;
# the personal Mac and the CI runner already had brew on PATH, so it never
# showed).  Apple Silicon installs to /opt/homebrew, Intel to /usr/local.
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
if [ -x /opt/homebrew/bin/brew ]; then eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then eval "$(/usr/local/bin/brew shellenv)"
else echo "bootstrap: Homebrew did not install; stopping" >&2; exit 1; fi
brew update
brew upgrade


# sync dot files

# setup python
brew install pyenv

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# only install if the versions don't already exist
pyenv install -s 3.10.0
pyenv install -s 3.11.6
pyenv install -s 3.11.9
pyenv install -s 3.12.7
pyenv local

# poetry
curl -sSL https://install.python-poetry.org | python3 -

# uv — primary python toolchain (interpreters, venvs, packages);
# pyenv/poetry above are kept for legacy projects only
curl -LsSf https://astral.sh/uv/install.sh | sh
# installer targets ~/.local/bin, which isn't on PATH yet in this shell
export PATH="$HOME/.local/bin:$PATH"
# pre-install the default interpreter (uv auto-downloads others on demand)
uv python install 3.12

# symlink (reads DOTFILES_PROFILE: the work manifest skips the personal files)
python3 "$REPO_ROOT/main.py"

# ghostty config (macOS reads from Application Support, not XDG)
ln -s -f "$REPO_ROOT/ghostty/config" "$HOME/Library/Application Support/com.mitchellh.ghostty/config"

# ghostty cursor shaders
if [ ! -d "$HOME/Library/Application Support/com.mitchellh.ghostty/shaders" ]; then
    git clone https://github.com/sahaj-b/ghostty-cursor-shaders \
        "$HOME/Library/Application Support/com.mitchellh.ghostty/shaders"
fi

# brew bundle is part of Homebrew itself now; tapping homebrew/bundle errors.

# brew bundle --file ~/.config/Brewfile cleanup --force
# brew bundle --file ~/.config/Brewfile dump
# `brew' filters the environment down to HOMEBREW_* before it reads the
# Brewfile, so the profile and the build gates travel as mirrors.
# No --no-lock: Homebrew 7 rejects it (bundle has no lockfile any more).
export HOMEBREW_DOTFILES_PROFILE="$DOTFILES_PROFILE"
export HOMEBREW_INCLUDE_EMACS_MAC="${INCLUDE_EMACS_MAC:-}"
export HOMEBREW_INCLUDE_EMACS_SRC="${INCLUDE_EMACS_SRC:-}"
export HOMEBREW_INCLUDE_EMACS_PLUS="${INCLUDE_EMACS_PLUS:-t}"
# Homebrew 7 loads formulae and casks from third-party taps only once the
# tap is trusted (`brew trust`); a fresh machine has trusted nothing, so
# the bundle would refuse aerospace, borders, k9s, mirrord, terraform-ls,
# tldr and aliases.  Trust exactly the taps the Brewfile names -- its
# `tap` lines and the org/tap/name references -- and nothing else.
{ sed -nE 's/^tap "([^"]+)".*/\1/p' "$REPO_ROOT/files/.config/Brewfile"
  sed -nE 's/^(brew|cask) "([^/"]+\/[^/"]+)\/[^"]+".*/\2/p' "$REPO_ROOT/files/.config/Brewfile"
} | sort -u | while IFS= read -r t; do
    # trust FIRST: Homebrew 7 refuses to tap an untrusted tap ("Cannot tap ...:
    # invalid syntax in tap!" -- measured 2026-09-14 on CI and locally)
    brew trust --tap "$t" >/dev/null 2>&1 || echo "bootstrap: could not trust tap $t (brew trust)" >&2
    brew tap "$t" >/dev/null 2>&1 || echo "bootstrap: could not tap $t" >&2
done
if ! brew bundle --force --file="$REPO_ROOT/files/.config/Brewfile"; then
    critical "brew bundle (missing entries: $(brew bundle check --file="$REPO_ROOT/files/.config/Brewfile" --verbose 2>&1 | grep -vE '^Checking|satisfied' | tr '\n' ' ' | cut -c1-300))"
fi

# syncthing folders (install/service via Brewfile; hub provisioning in hub/).
# Registers folders with the local daemon idempotently — creates the dir if
# missing, so this works on a fresh machine. Device pairing/sharing stays
# manual in the GUI (localhost:8384); folder IDs are the rendezvous keys.
# NEVER on the work profile: ~/kb there is a local tree, and pairing it
# with the personal notes would carry work notes to personal devices
# (work-security-audit.org S7).
if personal; then
    "$REPO_ROOT/files/.local/bin/st-ensure-folder" kb "$HOME/kb"
fi
# zinit (plugin manager for zsh - replaces oh-my-zsh)
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi


# if the fzf install script is at /usr/local/opt/fzf/install then ins
if [ -f /usr/local/opt/fzf/install ]; then
    yes | /usr/local/opt/fzf/install
fi

if [ -f /opt/homebrew/opt/fzf/install ]; then
    yes | /opt/homebrew/opt/fzf/install
fi


# Note: zsh-autosuggestions and zsh-syntax-highlighting are now
# managed by zinit (installed automatically on first shell launch)


# AWS cli v2
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /

# tmuxinator comes from the Brewfile: `gem install' ran under Apple's Ruby
# 2.6 on a fresh Mac and failed on the system gem directory.

# tmux plugin manager (TPM)
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

# install TPM plugins (non-interactive)
"$HOME/.tmux/plugins/tpm/bin/install_plugins"

# how-2
npm install -g how-2



# latex (for org-latex-preview)
eval "$(/usr/libexec/path_helper)"
sudo tlmgr update --self
sudo tlmgr install dvipng dvisvgm

# fonts: declared in files/.config/Brewfile and installed by the
# `brew bundle` call above -- including the full Nerd Fonts catalogue.
# Two are load-bearing rather than cosmetic (the SVG chrome font and the
# font the metric corrections derive from); see ~/.zetta.d/FONTS.org.

# emacs.  The other four distributions (Spacemacs, Doom, Prelude, Centaur)
# are behind INCLUDE_OTHER_DISTROS inside the script: t by default on the
# personal profile, f at work; the emacs-mac and source builds keep their
# own gates (files/.zshrc).
if [ -z "${INCLUDE_OTHER_DISTROS:-}" ]; then
    if personal; then export INCLUDE_OTHER_DISTROS=t; else export INCLUDE_OTHER_DISTROS=f; fi
fi
chmod +x "$REPO_ROOT/install_emacs_distros.sh"
# Its exit status is the LAST section's: after the Emacs build it also builds
# the optional canvas Rust module, whose failure must not read as a failed
# Emacs.  The critical question is whether the Emacs bundle exists.
"$REPO_ROOT/install_emacs_distros.sh" || echo "bootstrap: install_emacs_distros.sh ended with exit $? (see its output above; the Emacs bundle is checked next)" >&2
if [ "${INCLUDE_EMACS_SRC:-}" = t ]; then
    if [ -x "$HOME/Applications/EmacsSrc.app/Contents/MacOS/Emacs" ]; then
        echo "bootstrap: source-built Emacs present: $("$HOME/Applications/EmacsSrc.app/Contents/MacOS/Emacs" --version 2>/dev/null | head -1)"
    else
        critical "the source-built Emacs is missing after install_emacs_source.sh (re-run: INCLUDE_EMACS_SRC=t $REPO_ROOT/install_emacs_source.sh 2>&1 | tee ~/emacs-src-build.log)"
    fi
fi

# zemacs shims: one command per installed Emacs build (emacs-src-latest,
# emacs-plus-31, ...).  Generated rather than tracked, because the set depends
# on what is actually installed on this machine.  Re-run `zemacs shims` after
# installing or removing a build.
if [ -x "$HOME/bin/zemacs" ]; then
    "$HOME/bin/zemacs" shims
fi

# lolipop cursor animation: a dynamic module built against emacs-plus@31's
# headers, so only where that formula is installed (INCLUDE_EMACS_PLUS=t)
if [ ! -d "$HOME/.zetta.d/source/lib/lolipop" ] && brew --prefix emacs-plus@31 >/dev/null 2>&1; then
    git clone https://github.com/RadioNoiseE/lolipop /tmp/lolipop
    cd /tmp/lolipop
    make EMACS_INCLUDE="$(brew --prefix emacs-plus@31)/include"
    mkdir -p "$HOME/.zetta.d/source/lib/lolipop"
    cp lolipop-mode.el lolipop-core.dylib "$HOME/.zetta.d/source/lib/lolipop/"
    cd "$REPO_ROOT"
    rm -rf /tmp/lolipop
fi

# zetta.d (emacs configuration)
if [ -d "$HOME/.zetta.d" ]; then
    cd "$HOME/.zetta.d"
    git pull
else
    git clone https://github.com/chiply/.zetta.d.git "$HOME/.zetta.d" || critical "git clone of .zetta.d"
fi
# The profile must be in place BEFORE anything loads init.el: bin/zetta
# substitutes the full-profile example when ~/.zetta.el is missing, and
# the full profile builds and starts the personal apps.  Same rule as the
# hub bootstrap; never overwritten, the file is the owner's.
if ! personal && [ ! -f "$HOME/.zetta.el" ] && [ -f "$HOME/.zetta.d/templates/zetta.work.el" ]; then
    cp "$HOME/.zetta.d/templates/zetta.work.el" "$HOME/.zetta.el"
    echo "bootstrap: installed the work profile as ~/.zetta.el"
fi

# claude code notification hooks
# main.py already symlinked ~/.claude/claude-notify.sh; this merges the two
# settings.json entries that invoke it.  settings.json itself stays untracked
# because it also carries machine- and account-specific keys.  Placed here
# because it needs jq (brew bundle, above) and the zetta-notify entry point
# from .zetta.d (just above).
"$REPO_ROOT/install_claude_hooks.sh"

## language servers (not all should be installed into global scope, eg python)
# TODO move this to Brewfile
brew install npm
npm install -g vscode-json-languageserver
npm install -g typescript-language-server typescript
npm install -g eslint
npm install -g @github/copilot-language-server
npm i -g svelte-language-server

# sql language server: table/column completion in sql-mode buffers via
# lsp-mode (wired up in ~/source_code/sql-practice/elisp/sql-practice-lsp.el,
# which expects the binary at ~/go/bin/sqls — go install's default GOBIN)
go install github.com/sqls-server/sqls@latest


# nvm node
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
# download and sets current version of node
nvm install node

# completions
# just --completions zsh > just.zsh

export GRAPHVIZ_DIR="$(brew --prefix graphviz)"


# NOTE -- leaving out of my config until i get automated install for go
# markdownfmt
# go install github.com/shurcooL/markdownfmt@latest

# install mathjax
npm i mathjax

# signal-cli daemon (launch at login)
# set SIGNAL_PHONE in your environment (e.g. +15551234567) before running, or
# skip this block if you don't use signal-cli
mkdir -p ~/Library/LaunchAgents
if personal && [ -n "${SIGNAL_PHONE:-}" ]; then
    sed "s|__SIGNAL_PHONE__|$SIGNAL_PHONE|g" \
        "$REPO_ROOT/files/.config/signal-cli/signal-cli.plist" \
        > ~/Library/LaunchAgents/org.asamk.signal-cli.plist
    launchctl bootstrap "gui/$(id -u)" ~/Library/LaunchAgents/org.asamk.signal-cli.plist 2>/dev/null
fi

# rotating wallpaper (every 15 minutes) and the Aura frame sync: personal
# only (500 downloads, two LaunchAgents, mail through msmtp; the work
# manifest does not even link files/.config/wallpaper).
if personal; then
    mkdir -p "$HOME/Wallpapers"
    chmod +x ~/.config/wallpaper/rotate-wallpaper.sh
    chmod +x ~/.config/wallpaper/download-wallpapers.sh
    ~/.config/wallpaper/download-wallpapers.sh
    sed "s|__HOME__|$HOME|g" \
        "$REPO_ROOT/files/.config/wallpaper/rotate-wallpaper.plist" \
        > ~/Library/LaunchAgents/com.zetta.rotate-wallpaper.plist
    launchctl bootstrap "gui/$(id -u)" ~/Library/LaunchAgents/com.zetta.rotate-wallpaper.plist 2>/dev/null

    # aura frame sync (opt-in): emails new ~/Wallpapers images to an Aura frame
    # set BOTH AURA_FRAME_EMAIL (Aura app -> frame -> Settings -> Email to frame)
    # and AURA_MSMTP_ACCOUNT (msmtp account whose from= is your Aura login email),
    # e.g. in ~/.zshenv.local, before running. See files/.config/wallpaper/aura-sync.sh
    # There is no default account: an account name is a personal identifier.
    chmod +x ~/.config/wallpaper/aura-sync.sh
    if [ -n "${AURA_FRAME_EMAIL:-}" ] && [ -z "${AURA_MSMTP_ACCOUNT:-}" ]; then
        echo "aura-sync: AURA_FRAME_EMAIL is set but AURA_MSMTP_ACCOUNT is not; skipping the LaunchAgent" >&2
    fi
    if [ -n "${AURA_FRAME_EMAIL:-}" ] && [ -n "${AURA_MSMTP_ACCOUNT:-}" ]; then
        sed -e "s|__HOME__|$HOME|g" \
            -e "s|__AURA_FRAME_EMAIL__|$AURA_FRAME_EMAIL|g" \
            -e "s|__AURA_MSMTP_ACCOUNT__|$AURA_MSMTP_ACCOUNT|g" \
            "$REPO_ROOT/files/.config/wallpaper/aura-sync.plist" \
            > ~/Library/LaunchAgents/com.zetta.aura-sync.plist
        launchctl bootstrap "gui/$(id -u)" ~/Library/LaunchAgents/com.zetta.aura-sync.plist 2>/dev/null
    fi
fi

# shottr screenshots directory
mkdir -p "$HOME/Screenshots"
defaults write cc.ffitch.shottr saveTo -string "$HOME/Screenshots"
defaults write cc.ffitch.shottr afterGrabSave -bool true
defaults write cc.ffitch.shottr afterGrabCopy -bool true
defaults write cc.ffitch.shottr afterGrabShow -bool false

# snowsql: a previous job's tool, maybe the next's -- personal by default,
# INCLUDE_SNOWFLAKE=t to opt in at work
if personal || [ "${INCLUDE_SNOWFLAKE:-}" = t ]; then
    brew install --cask snowflake-snowsql
fi

# ubersicht widgets directory + simple-bar
mkdir -p "$HOME/Library/Application Support/Übersicht/widgets"
if [ ! -d "$HOME/Library/Application Support/Übersicht/widgets/simple-bar" ]; then
    git clone https://github.com/Jean-Tinland/simple-bar \
        "$HOME/Library/Application Support/Übersicht/widgets/simple-bar"
fi

# Patch top bar (remove widgets moved to bottom bar)
chmod +x ~/.config/simple-bar-server/patch-top-bar.sh
~/.config/simple-bar-server/patch-top-bar.sh

# simple-bar-bottom (system stats bar)
if [ ! -d "$HOME/Library/Application Support/Übersicht/widgets/simple-bar-bottom" ]; then
    cp -r "$HOME/Library/Application Support/Übersicht/widgets/simple-bar" \
        "$HOME/Library/Application Support/Übersicht/widgets/simple-bar-bottom"
fi
chmod +x ~/.config/simple-bar-server/patch-bottom-bar.sh
~/.config/simple-bar-server/patch-bottom-bar.sh

# simple-bar-server (event-driven refresh for simple-bar)
if [ ! -d "$HOME/.simple-bar-server" ]; then
    git clone https://github.com/Jean-Tinland/simple-bar-server.git "$HOME/.simple-bar-server"
fi
cp ~/.config/simple-bar-server/watch-focus.sh "$HOME/.simple-bar-server/watch-focus.sh"
chmod +x "$HOME/.simple-bar-server/watch-focus.sh"
cd "$HOME/.simple-bar-server" && npm install
cd "$HOME/.files"

# launchd keeps the server and focus watcher alive (KeepAlive + RunAtLoad)
sed "s|__HOME__|$HOME|g" \
    "$REPO_ROOT/files/.config/simple-bar-server/simple-bar-server.plist" \
    > ~/Library/LaunchAgents/com.zetta.simple-bar-server.plist
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.zetta.simple-bar-server.plist 2>/dev/null

sed "s|__HOME__|$HOME|g" \
    "$REPO_ROOT/files/.config/simple-bar-server/simple-bar-focus-watcher.plist" \
    > ~/Library/LaunchAgents/com.zetta.simple-bar-focus-watcher.plist
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.zetta.simple-bar-focus-watcher.plist 2>/dev/null

# k9s skins
OUT="${XDG_CONFIG_HOME:-$HOME/Library/Application Support}/k9s/skins"
mkdir -p "$OUT"
curl -L https://github.com/catppuccin/k9s/archive/main.tar.gz | tar xz -C "$OUT" --strip-components=2 k9s-main/dist

# ── summary ──────────────────────────────────────────────────────────
if [ ${#BOOTSTRAP_FAILED[@]} -gt 0 ]; then
    echo "bootstrap: FINISHED WITH ${#BOOTSTRAP_FAILED[@]} CRITICAL FAILURE(S):" >&2
    printf '  - %s\n' "${BOOTSTRAP_FAILED[@]}" >&2
    exit 1
fi
echo "bootstrap: finished, profile $DOTFILES_PROFILE, no critical failure"
