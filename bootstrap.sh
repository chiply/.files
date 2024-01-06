
cd ~
mkdir -p .tmux/themes

touch ~/.localsecrets

# macos thing
xcode-select --install

# install brew
/bin/bash \
    -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew update
brew upgrade

export GRAPHVIZ_DIR="$(brew --prefix graphviz)"

# sync dot files
brew install git python
python3 ~/.files/main.py

# install bundle
brew tap Homebrew/bundle

# installs everything ~/Brewfile
# if the fzf install script is at /usr/local/opt/fzf/install then ins
if [ -f /usr/local/opt/fzf/install ]; then
    yes | /usr/local/opt/fzf/install
fi

if [ -f /opt/homebrew/opt/fzf/install ]; then
    yes | /opt/homebrew/opt/fzf/install
fi

# to update the brewfile and the system
# uninstalls anything not included in the brew bundle file:
# brew bundle --file ~/.config/Brewfile --force cleanup
# .. manual edits
# rewrites the Brewfile:
# brew bundle --file ~/.config/Brewfile dump

# znap: znap is a plugin manager for zsh that's simple, fast, and easy
# to use.
git clone --depth 1 -- https://github.com/marlonrichert/zsh-snap.git
source zsh-snap/install.zsh

# install autocomplete: incremental narrowing completing read
znap source marlonrichert/zsh-autocomplete

# install autosuggestions: fish-like autosuggestions for zsh
git clone \
    https://github.com/zsh-users/zsh-autosuggestions \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# AWS cli v2
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /

# tmuxinator: manage complex tmux sessions easily
gem install tmuxinator

# cheat.sh (not cheat)
curl -s https://cht.sh/:cht.sh | \
    sudo tee /usr/local/bin/cht.sh && \
    sudo chmod +x /usr/local/bin/cht.sh

# how-2
npm install -g how-2

# syntax highlighting in the command line
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/zsh-syntax-highlighting
source ./zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# emacs
chmod +x ./install_emacs_distros.sh && ./install_emacs_distros.sh

## language servers (not all should be installed into global scope, eg python)
npm install -g vscode-json-languageserver

# nvm ode
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

# download and sets current version of node
nvm install node


# completions
just --completions zsh > just.zsh




git clone https://github.com/supercrabtree/k $ZSH_CUSTOM/plugins/k
