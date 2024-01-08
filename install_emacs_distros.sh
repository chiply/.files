######################################################################
# chemacs
######################################################################
[ ! -e ~/chemacs ] || rm -rf ~/chemacs
git clone https://github.com/plexus/chemacs.git && \
    cd chemacs && \
    ./install.sh


######################################################################
# spacemacs
######################################################################
if [ -d ~/.spacemacs.d ]; then
    cd ~/.spacemacs.d
    git pull
else
    git clone https://github.com/syl20bnr/spacemacs ~/.spacemacs.d
fi
    

######################################################################
# doom
######################################################################
if [ -d ~/.doom.d ]; then
    cd ~/.doom.d
    git pull
else
    git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.doom.d && \
        ~/.doom.d/bin/doom install
fi


######################################################################
# prelude
######################################################################
if [ -d ~/.prelude.d ]; then
    cd ~/.prelude.d
    git pull
else
    export PRELUDE_INSTALL_DIR="$HOME/.prelude.d" && \
        curl \
            -L https://github.com/bbatsov/prelude/raw/master/utils/installer.sh  \
            | sh
fi


######################################################################
# cetnaur
######################################################################
if [ -d ~/.centaur.d ]; then
    cd ~/.centaur.d
    git pull
else
    git clone --depth 1 https://github.com/seagle0128/.emacs.d.git ~/.centaur.d
fi



