source ~/.localsecrets

# this script assumes thigns have already been bootstrapped
export PATH=$HOME/bin:/usr/local/bin:/opt/homebrew:$PATH



source ~/zsh-snap/znap.zsh

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="refined"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
zstyle ':omz:update' frequency 1

COMPLETION_WAITING_DOTS="true"

plugins=(
    codeclimate common-aliases copybuffer copyfile copypath dash
    dirhistory docker docker-compose extract fd frontend-search gh
    brew git-extras gitfast git-lfs history httpie jsontools pip
    ripgrep safe-paste screen terraform tmux themes tmuxinator
    zsh-autosuggestions
)
source $ZSH/oh-my-zsh.sh



#### language specific settings
# ruby
export GEM_HOME="$HOME/.gem"

# node

# rust

# go

# python




# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# mcfly
#export MCFLY_RESULTS_SORT=LAST_RUN
#export MCFLY_RESULTS=50
#export MCFLY_FUZZY=5
#export MCFLY_LIGHT=TRUE
#export MCFLY_DISABLE_MENU=TRUE
#eval "$(mcfly init zsh)"

# completion
autoload bashcompinit && bashcompinit
autoload -Uz compinit && compinit

# be able to tab expand aliases
zstyle ':completion:*' completer _expand_alias _complete _ignored
zstyle ':completion:*' regular true

# aws completion
complete -C '/usr/local/bin/aws_completer' aws
complete -C '/usr/local/bin/aws_completer' awslocal





# autosuggestion
znap source marlonrichert/zsh-autocomplete
bindkey autosuggest-fetch '^ '

# autocompletion
zstyle ':autocomplete:*' min-input 2
zstyle ':autocomplete:*' min-delay 0.001
zstyle ':autocomplete:*' list-lines 6
zstyle ':autocomplete:history-search:*' list-lines 6
zstyle ':autocomplete:history-incremental-search-*:*' list-lines 6
zstyle ':autocomplete:*' insert-unambiguous yes


# syntax highlighting
source ./zsh-syntax-highlighting/zsh-syntax-highlighting.zsh





# aliases
source ~/.aliases/index


# for vterm directory tracking
vterm_printf(){
    if [ -n "$TMUX" ] && ([ "${TERM%%-*}" = "tmux" ] || [ "${TERM%%-*}" = "screen" ] ); then
        # Tell tmux to pass the escape sequences through
        printf "\ePtmux;\e\e]%s\007\e\\" "$1"
    elif [ "${TERM%%-*}" = "screen" ]; then
        # GNU screen (screen, screen-256color, screen-256color-bce)
        printf "\eP\e]%s\007\e\\" "$1"
    else
        printf "\e]%s\e\\" "$1"
    fi
}


# from https://github.com/doomemacs/doomemacs/issues/3546

