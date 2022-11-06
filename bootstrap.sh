cd ~
touch ~/.localsecrets

# macos thing
xcode-select --install

# install brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# housekeeping
brew update
brew upgrade


# sync dot files
brew install git
#git clone https://github.com/chiply/.zetta.d

brew intall python
python3 ~/.files/main.py


# install bundle
brew tap Homebrew/bundle


# installs everything ~/Brewfile
brew bundle
# to update the brewfile and the system
# uninstalls anything not included in the brew bundle file
# brew bundle --force cleanup
# .. manual edits
# rewrites the Brewfile
# brew bundle dump

# znap
git clone --depth 1 -- https://github.com/marlonrichert/zsh-snap.git
source zsh-snap/install.zsh





# install autocomplete
znap source marlonrichert/zsh-autocomplete

# install autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions



# aws cli v2
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /



# tmuxinator
gem install tmuxinator

# cheat.sh (not cheat)
curl -s https://cht.sh/:cht.sh | \
    sudo tee /usr/local/bin/cht.sh && \
    sudo chmod +x /usr/local/bin/cht.sh

# how-2
npm install -g how-2


git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/zsh-syntax-highlighting
source ./zsh-syntax-highlighting/zsh-syntax-highlighting.zsh





# user friendly emacs distros
git clone https://github.com/plexus/chemacs.git
cd chemacs
./install.sh
# note the ~/.emacs-profiles.el file which refers to these directories

## spacemacs
# git clone https://github.com/syl20bnr/spacemacs ~/.spacemacs.d

## doom
# git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.doom.d && \
    # ~/.doom.d/bin/doom install


