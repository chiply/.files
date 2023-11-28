cd ~
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
brew bundle
# to update the brewfile and the system
# uninstalls anything not included in the brew bundle file:
# brew bundle --force cleanup
# .. manual edits
# rewrites the Brewfile:
# brew bundle dump

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

# user friendly emacs distros
git clone https://github.com/plexus/chemacs.git
cd chemacs
./install.sh
# note the ~/.emacs-profiles.el file which refers to these directories

## spacemacs
# clone or update spacemacs
#if [ -d "~/.spacemacs.d" ]; then
    #cd ~/.spacemacs.d
    #git pull
#else
    #git clone https://github.com/syl20bnr/spacemacs ~/.spacemacs.d
#fi
    

## doom
# git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.doom.d && \
    # ~/.doom.d/bin/doom install



## language servers
npm install -g vscode-json-languageserver
