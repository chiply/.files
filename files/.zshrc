source ~/.localsecrets
source ~/.tokens

# this script assumes thigns have already been bootstrapped
export PATH=$HOME/bin:/usr/local/bin:/opt/homebrew:$PATH

source ~/zsh-snap/znap.zsh

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
#ZSH_THEME="refined"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
zstyle ':omz:update' frequency 1

COMPLETION_WAITING_DOTS="true"

plugins=(
    codeclimate common-aliases aliases alias-finder copybuffer
    copyfile copypath dirhistory docker docker-compose extract fd
    frontend-search gh brew git-extras gitfast git-lfs git-prompt
    history httpie jsontools pip ripgrep safe-paste screen terraform
    tmux themes tmuxinator zsh-autosuggestions kube-ps1 aws npm
    dirpersist kubectl poetry zsh-syntax-highlighting direnv
)
source $ZSH/oh-my-zsh.sh
export KUBE_PS1_BINARY=kubectl
export KUBE_PS1_NS_ENABLE=true



#### language specific settings
# ruby
export GEM_HOME="$HOME/.gem"

# node

# rust

# go

# python




# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh




# completion
autoload bashcompinit && bashcompinit
autoload -Uz compinit && compinit

# expand alias this is such a critical binding as it allows you to
# acheive the convenience of aliases.  When the completion is
# unambiguous, this behaves like yasnippet, otherwise it completes for
# aliases and then expands.  Expansion can be triggered manually with
# the keybinding
zstyle ':completion:*' completer _expand_alias _complete _ignored
zle -N _expand_alias # to avoid error
bindkey "^Xe" _expand_alias
zstyle ':completion:*' regular true

# aws completion
complete -C '/usr/local/bin/aws_completer' aws
complete -C '/usr/local/bin/aws_completer' awslocal





# autosuggestion
znap source marlonrichert/zsh-autocomplete
bindkey "^ " autosuggest-fetch
bindkey "^f" forward-char
bindkey "^w" forward-word
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# autocompletion
zstyle ':autocomplete:*' min-input 2
zstyle ':autocomplete:*' min-delay 0.001
zstyle ':autocomplete:*' list-lines 6
zstyle ':autocomplete:history-search:*' list-lines 6
zstyle ':autocomplete:history-incremental-search-*:*' list-lines 6
zstyle ':autocomplete:*' insert-unambiguous yes


# syntax highlighting
#source ~/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh





# aliases
source ~/.aliases/index


# kubernetes autocompletion
source <(kubectl completion zsh)

alias cat="bat --theme=GitHub --style=\"numbers,changes,header\""
alias bat="bat --theme=GitHub --style=\"numbers,changes,header\""





# pyenv
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"



# language server specific settings
export LSP_USE_PLISTS=true
unexport VIRTUAL_ENV

export GOPATH=$HOME/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin


#export BROOT_CONFIG_DIR=~/.config/broot
#source ~/.config/broot/launcher/bash/br

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
#[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion



export PATH="$HOME/.local/bin:$PATH"


# move this to bootstrap -- need to load before


# PROMPT
RPROMPT=''
export SHOW_AWS_PROMPT=false

function preexec() {
  timer=$(print -P %D{%s%3.})
}

function precmd() {
  timeprompt=""	
  if [ $timer ]; then
    now=$(print -P %D{%s%3.})
    local d_ms=$(($now - $timer))
    local d_s=$((d_ms / 1000))
    local ms=$((d_ms % 1000))
    local s=$((d_s % 60))
    local m=$(((d_s / 60) % 60))
    local h=$((d_s / 3600))

    if   ((h > 0)); then timeprompt=${h}h${m}m${s}s
    elif ((m > 0)); then timeprompt=${m}m${s}.$(printf $(($ms / 100)))s # 1m12.3s
    elif ((s > 9)); then timeprompt=${s}.$(printf %02d $(($ms / 10)))s # 12.34s
    elif ((s > 0)); then timeprompt=${s}.$(printf %03d $ms)s # 1.234s
    else timeprompt=${ms}ms
    fi
    timeprompt="%B%F{yellow}${timeprompt} %f%b"
    unset timer
  fi
}

export PROMPT=$'\n''%n@%m $(git rev-parse --show-toplevel 2> /dev/null | xargs basename || pwd ):$(git_super_status) $timeprompt$(date +%d.%m.%y-%H:%M:%S)'$'\n''[pyenv:$(pyenv local)]*$(aws_prompt_info)*$(kube_ps1)'$'\n'
#'x---}-> '


# for vterm directory tracking
if [[ "$INSIDE_EMACS" == 'vterm' ]] \
&& [[ -n ${EMACS_VTERM_PATH} ]] \
&& [[ -f ${EMACS_VTERM_PATH}/etc/emacs-vterm-zsh.sh ]]; then
source ${EMACS_VTERM_PATH}/etc/emacs-vterm-zsh.sh
fi


# pnpm
export PNPM_HOME="/Users/charles.baker/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

. "$HOME/.cargo/env"
