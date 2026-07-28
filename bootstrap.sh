#!/bin/bash

# resolve the directory containing this script so the repo can live anywhere
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Prompt for sudo password upfront and keep alive
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

mkdir -p ~/.tmux/themes
mkdir -p ~/.config/tmux-powerline/themes
mkdir -p ~/.config/tmux-powerline/segments
mkdir -p ~/.config/gitmux
mkdir -p "$HOME/Library/Application Support/com.mitchellh.ghostty"

touch ~/.localsecrets
touch ~/.tokens

# macos thing - skip if already installed
if ! xcode-select -p &>/dev/null; then
    xcode-select --install
    # Wait for installation to complete
    until xcode-select -p &>/dev/null; do
        sleep 5
    done
fi

# install brew (non-interactive)
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
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

# uv
curl -LsSf https://astral.sh/uv/install.sh | sh

# symlink
python "$REPO_ROOT/main.py"

# ghostty config (macOS reads from Application Support, not XDG)
ln -s -f "$REPO_ROOT/ghostty/config" "$HOME/Library/Application Support/com.mitchellh.ghostty/config"

# ghostty cursor shaders
if [ ! -d "$HOME/Library/Application Support/com.mitchellh.ghostty/shaders" ]; then
    git clone https://github.com/sahaj-b/ghostty-cursor-shaders \
        "$HOME/Library/Application Support/com.mitchellh.ghostty/shaders"
fi

# install bundle
brew tap Homebrew/bundle

# brew bundle --file ~/.config/Brewfile --force cleanup
# brew bundle --file ~/.config/Brewfile dump
brew bundle \
     --force --no-lock \
     --file="$REPO_ROOT/files/.config/Brewfile"

# syncthing folders (install/service via Brewfile; hub provisioning in hub/).
# Registers folders with the local daemon idempotently — creates the dir if
# missing, so this works on a fresh machine. Device pairing/sharing stays
# manual in the GUI (localhost:8384); folder IDs are the rendezvous keys.
"$REPO_ROOT/files/.local/bin/st-ensure-folder" kb "$HOME/kb"
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

# tmuxinator: manage complex tmux sessions easily
gem install tmuxinator

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

# fonts
brew install --cask font-terminus
brew install --cask font-jetbrains-mono-nerd-font
brew install --cask font-terminess-ttf-nerd-font

# emacs
chmod +x "$REPO_ROOT/install_emacs_distros.sh" && "$REPO_ROOT/install_emacs_distros.sh"

# lolipop cursor animation (requires emacs-plus@31)
if [ ! -d "$HOME/.zetta.d/source/lib/lolipop" ]; then
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
    git clone https://github.com/chiply/.zetta.d.git "$HOME/.zetta.d"
fi

## language servers (not all should be installed into global scope, eg python)
# TODO move this to Brewfile
brew install npm
npm install -g vscode-json-languageserver
npm install -g eslint
npm install -g @github/copilot-language-server
npm i -g svelte-language-server


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
if [ -n "${SIGNAL_PHONE:-}" ]; then
    sed "s|__SIGNAL_PHONE__|$SIGNAL_PHONE|g" \
        "$REPO_ROOT/files/.config/signal-cli/signal-cli.plist" \
        > ~/Library/LaunchAgents/org.asamk.signal-cli.plist
    launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/org.asamk.signal-cli.plist 2>/dev/null
fi

# rotating wallpaper (every 15 minutes)
mkdir -p "$HOME/Wallpapers"
chmod +x ~/.config/wallpaper/rotate-wallpaper.sh
chmod +x ~/.config/wallpaper/download-wallpapers.sh
~/.config/wallpaper/download-wallpapers.sh
sed "s|__HOME__|$HOME|g" \
    "$REPO_ROOT/files/.config/wallpaper/rotate-wallpaper.plist" \
    > ~/Library/LaunchAgents/com.zetta.rotate-wallpaper.plist
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.zetta.rotate-wallpaper.plist 2>/dev/null

# shottr screenshots directory
mkdir -p "$HOME/Screenshots"
defaults write cc.ffitch.shottr saveTo -string "$HOME/Screenshots"
defaults write cc.ffitch.shottr afterGrabSave -bool true
defaults write cc.ffitch.shottr afterGrabCopy -bool true
defaults write cc.ffitch.shottr afterGrabShow -bool false

# snowsql
brew install --cask snowflake-snowsql

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

