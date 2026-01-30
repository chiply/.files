mkdir -p ~/.tmux/themes

touch ~/.localsecrets
touch ~/.tokens

# macos thing
xcode-select --install

# install brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
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
pyenv install -v 3.10.0
pyenv install -v 3.11.6
pyenv install -v 3.11.9
pyenv install -v 3.12.7
pyenv local

# poetry
curl -sSL https://install.python-poetry.org | python3 -

# uv
curl -LsSf https://astral.sh/uv/install.sh | sh

# symlink
python ~/.files/main.py


# install bundle
brew tap Homebrew/bundle

# brew bundle --file ~/.config/Brewfile --force cleanup
# brew bundle --file ~/.config/Brewfile dump
brew bundle \
     --force --no-lock \
     --file=~/.files/files/.config/Brewfile
# zinit (plugin manager for zsh - replaces oh-my-zsh)
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
mkdir -p "$(dirname $ZINIT_HOME)"
git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"


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

# how-2
npm install -g how-2



# emacs
chmod +x ~/.files/install_emacs_distros.sh && ~/.files/install_emacs_distros.sh

## language servers (not all should be installed into global scope, eg python)
npm install -g vscode-json-languageserver
npm install -g eslint
;;npm install -g @github/copilot-language-server
npm i -g svelte-language-server


# nvm node
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
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

# snowsql
brew install --cask snowflake-snowsql

# k9s skins
OUT="${XDG_CONFIG_HOME:-$HOME/Library/Application Support}/k9s/skins"
mkdir -p "$OUT"
curl -L https://github.com/catppuccin/k9s/archive/main.tar.gz | tar xz -C "$OUT" --strip-components=2 k9s-main/dist

