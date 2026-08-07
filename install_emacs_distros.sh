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


######################################################################
# emacs-mac (jdtsmith experimental fork, Emacs 30 branch)
#
# Side-by-side trial next to emacs-plus@31: retina-correct image
# rendering (the NS port composites scaled images at logical
# resolution; this port samples at backing resolution).  Gated on
# INCLUDE_EMACS_MAC=t (files/.zshrc); build deps come from the
# Brewfile's gated section.  Installs as ~/Applications/EmacsMac.app
# — never touches /Applications/Emacs.app (the emacs-plus symlink).
#
# The chemacs profile "zetta-mac" points at ~/.zetta-mac.d, a
# separate clone of the config: elpaca bytecode/native-lisp compile
# per-Emacs-version, and mixing 30.x with the 31-compiled builds in
# ~/.zetta.d replays the 2026-07 version-skew saga.  The clone's
# elpaca package sources are seeded from ~/.zetta.d when available to
# skip re-cloning ~340 repos.
######################################################################
if [ "${INCLUDE_EMACS_MAC}" = "t" ]; then
    TS025="$(brew --prefix tree-sitter@0.25 2>/dev/null || echo /opt/homebrew/opt/tree-sitter@0.25)"

    if [ ! -d ~/source_code/emacs-mac ]; then
        git clone --depth 1 --branch emacs-mac-30_1_exp \
            https://github.com/jdtsmith/emacs-mac.git ~/source_code/emacs-mac
    fi

    if [ ! -d "$HOME/Applications/EmacsMac.app" ]; then
        mkdir -p "$HOME/Applications"
        cd ~/source_code/emacs-mac
        ./autogen.sh
        CFLAGS="-O2 -mcpu=native -I${TS025}/include" \
        LDFLAGS="-L${TS025}/lib" \
            ./configure --with-native-compilation --with-tree-sitter \
                        --enable-mac-app="$HOME/Applications" \
                        --enable-mac-self-contained
        make -j"$(sysctl -n hw.ncpu)"
        make install
        # self-contained app lands as Emacs.app in the target dir;
        # rename so it can never be confused with the daily driver
        mv "$HOME/Applications/Emacs.app" "$HOME/Applications/EmacsMac.app"
    fi

    # isolated config profile for the trial
    if [ ! -d ~/.zetta-mac.d ]; then
        git clone https://github.com/chiply/.zetta.d.git ~/.zetta-mac.d
        # seed package sources from the main checkout (big time-saver;
        # builds still compile fresh under the mac Emacs)
        if [ -d ~/.zetta.d/elpaca/sources ]; then
            mkdir -p ~/.zetta-mac.d/elpaca
            cp -R ~/.zetta.d/elpaca/sources ~/.zetta-mac.d/elpaca/sources
        fi
    fi
fi



