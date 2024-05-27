mkdir -p ~/.tmux/themes

touch ~/.localsecrets

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
echo doing pyenv stuff
export PYENV_ROOT="$HOME/.pyenv"
echo doing pyenv command
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
echo doing pyenv init
eval "$(pyenv init -)"

pyenv install -v 3.10.0
echo python version is $(python --version)
pyenv local

# poetry 
curl -sSL https://install.python-poetry.org | python3 -
mkdir -p ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/poetry
poetry completions zsh > \
       ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/poetry/_poetry

# symlink
python ~/.files/main.py


# install bundle
brew tap Homebrew/bundle

# brew bundle --file ~/.config/Brewfile --force cleanup
# brew bundle --file ~/.config/Brewfile dump
brew bundle \
     --force --no-lock \
     --file=~/.files/files/.config/Brewfile
# oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"


# if the fzf install script is at /usr/local/opt/fzf/install then ins
if [ -f /usr/local/opt/fzf/install ]; then
    yes | /usr/local/opt/fzf/install
fi

if [ -f /opt/homebrew/opt/fzf/install ]; then
    yes | /opt/homebrew/opt/fzf/install
fi


# znap: znap is a plugin manager for zsh that's simple, fast, and easy
# to use.
# Download Znap, if it's not there yet.
[[ -r ~/znap/znap.zsh ]] ||
    git clone --depth 1 -- \
        https://github.com/marlonrichert/zsh-snap.git ~/znap
source ~/znap/znap.zsh  # Start Znap

# install autocomplete: incremental narrowing completing read
# znap source marlonrichert/zsh-autocomplete

# install autosuggestions: fish-like autosuggestions for zsh
[ ! -e ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions ] || \
    rm -rf ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone \
    https://github.com/zsh-users/zsh-autosuggestions \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions


# AWS cli v2
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /

# tmuxinator: manage complex tmux sessions easily
gem install tmuxinator

# how-2
npm install -g how-2

# syntax highlighting in the command line
[ ! -e ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting ] || \
    rm -rf ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting


# emacs
chmod +x ~/.files/install_emacs_distros.sh && ~/.files/install_emacs_distros.sh

## language servers (not all should be installed into global scope, eg python)
npm install -g vscode-json-languageserver

# nvm ode
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




