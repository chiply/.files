source ~/.localsecrets
source ~/.tokens

# this script assumes thigns have already been bootstrapped
export PATH=$HOME/bin:/usr/local/bin:/opt/homebrew:$PATH


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
    common-aliases aliases copybuffer copyfile copypath
    dirhistory docker docker-compose extract
    gh brew git-extras gitfast git-lfs git-prompt
    history jsontools pip safe-paste terraform
    tmux tmuxinator zsh-autosuggestions kube-ps1 aws npm
    kubectl poetry zsh-syntax-highlighting direnv
)
source $ZSH/oh-my-zsh.sh

# kube-ps1 grayscale settings
export KUBE_PS1_BINARY=kubectl
export KUBE_PS1_NS_ENABLE=true
export KUBE_PS1_PREFIX=""
export KUBE_PS1_SUFFIX=""
export KUBE_PS1_CTX_COLOR=""
export KUBE_PS1_NS_COLOR=""
export KUBE_PS1_SYMBOL_ENABLE=false

# git-prompt grayscale settings
ZSH_THEME_GIT_PROMPT_PREFIX="["
ZSH_THEME_GIT_PROMPT_SUFFIX="]"
ZSH_THEME_GIT_PROMPT_SEPARATOR="|"
ZSH_THEME_GIT_PROMPT_STAGED="+"
ZSH_THEME_GIT_PROMPT_CONFLICTS="x"
ZSH_THEME_GIT_PROMPT_CHANGED="*"
ZSH_THEME_GIT_PROMPT_BEHIND="<"
ZSH_THEME_GIT_PROMPT_AHEAD=">"
ZSH_THEME_GIT_PROMPT_UNTRACKED="?"
ZSH_THEME_GIT_PROMPT_STASHED="$"
ZSH_THEME_GIT_PROMPT_CLEAN=""



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
autoload bashcompinit && bashcompinit -C
autoload -Uz compinit && compinit -C

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


# autosuggestion (using oh-my-zsh zsh-autosuggestions plugin)
bindkey "^ " autosuggest-fetch
bindkey "^f" forward-char
bindkey "^w" forward-word
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)


# aliases
source ~/.aliases/index


# kubernetes autocompletion (cached for faster startup)
if [[ ! -f ~/.zcompdump-kubectl ]] || [[ ~/.zcompdump-kubectl -ot $(which kubectl) ]]; then
  kubectl completion zsh > ~/.zcompdump-kubectl
fi
source ~/.zcompdump-kubectl

alias cat="bat --theme=GitHub --style=\"numbers,changes,header\""
alias bat="bat --theme=GitHub --style=\"numbers,changes,header\""





# pyenv lazy-loading - only initialize when first using pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
pyenv() {
  unfunction pyenv 2>/dev/null
  eval "$(command pyenv init -)"
  pyenv "$@"
}



# language server specific settings
export LSP_USE_PLISTS=true
unset VIRTUAL_ENV

export GOPATH=$HOME/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin


#export BROOT_CONFIG_DIR=~/.config/broot
#source ~/.config/broot/launcher/bash/br

# NVM lazy-loading - only initialize when first using node/npm/nvm
export NVM_DIR="$HOME/.config/nvm"

nvm() {
  unfunction nvm node npm npx 2>/dev/null
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  nvm "$@"
}
node() {
  unfunction nvm node npm npx 2>/dev/null
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  node "$@"
}
npm() {
  unfunction nvm node npm npx 2>/dev/null
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  npm "$@"
}
npx() {
  unfunction nvm node npm npx 2>/dev/null
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  npx "$@"
}



export PATH="$HOME/.local/bin:$PATH"


# move this to bootstrap -- need to load before


# PROMPT
RPROMPT=''
export SHOW_AWS_PROMPT=false

# Cache git info only on directory change
_last_pwd=""
_cached_git_root=""

function preexec() {
  timer=$(print -P %D{%s%3.})
}

function precmd() {
  # Timer logic
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
    elif ((m > 0)); then timeprompt=${m}m${s}.$(printf $(($ms / 100)))s
    elif ((s > 9)); then timeprompt=${s}.$(printf %02d $(($ms / 10)))s
    elif ((s > 0)); then timeprompt=${s}.$(printf %03d $ms)s
    else timeprompt=${ms}ms
    fi
    timeprompt="%B${timeprompt} %b"
    unset timer
  fi

  # Cache git root (only update on directory change)
  if [[ "$PWD" != "$_last_pwd" ]]; then
    _last_pwd="$PWD"
    _cached_git_root=$(git rev-parse --show-toplevel 2>/dev/null | xargs basename 2>/dev/null)
  fi
}

_kube_prompt() {
  local kp=$(kube_ps1)
  [[ -n "$kp" ]] && echo "$kp"$'\n'
}
PROMPT='%n@%m'$'\n''${_cached_git_root:-$(basename $PWD)}:$(git_super_status)'$'\n''$timeprompt$(date +%d.%m.%y-%H:%M:%S)'$'\n''$(_kube_prompt)$(pwd)'$'\n''> '

# how can I add current directory to the prompt



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

source ~/.sh_utility_functions.sh

. "$HOME/.local/share/../bin/env"

# snowsql
alias snowsql=/Applications/SnowSQL.app/Contents/MacOS/snowsql
