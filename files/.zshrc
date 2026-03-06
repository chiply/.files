source ~/.localsecrets
source ~/.tokens

# History
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY          # share history across tmux panes/sessions
setopt APPEND_HISTORY         # append rather than overwrite
setopt INC_APPEND_HISTORY     # write after each command, not on exit
setopt HIST_IGNORE_ALL_DUPS   # deduplicate
setopt HIST_REDUCE_BLANKS     # trim whitespace

# this script assumes things have already been bootstrapped
export PATH=$HOME/bin:/usr/local/bin:/opt/homebrew:$PATH

# ============================================================================
# ZINIT SETUP (replaces oh-my-zsh for faster startup)
# ============================================================================
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Auto-install zinit if not present
if [[ ! -d "$ZINIT_HOME" ]]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# ============================================================================
# DEFERRED COMPINIT (runs after prompt shows)
# ============================================================================
# Skip global compinit on Ubuntu/Debian
skip_global_compinit=1

# Deferred completion initialization
zinit ice wait'0' lucid atinit'
  autoload -Uz compinit
  autoload -Uz bashcompinit
  # Use cached completions if less than 24h old
  if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
    compinit
    bashcompinit
  else
    compinit -C
    bashcompinit -C
  fi
  # Completion settings
  zstyle ":completion:*" completer _expand_alias _complete _ignored
  zstyle ":completion:*" regular true
'
zinit light zdharma-continuum/null

# ============================================================================
# PLUGINS (loaded with turbo mode - after prompt shows)
# ============================================================================
# Essential plugins - load slightly after prompt
zinit ice wait'0' lucid
zinit light zsh-users/zsh-autosuggestions

zinit ice wait'0' lucid
zinit light zsh-users/zsh-syntax-highlighting

zinit ice wait'0' lucid
zinit light jonmosco/kube-ps1

# Direnv hook
zinit ice wait'0' lucid
zinit light ptavares/zsh-direnv

# OMZ plugins loaded via zinit (turbo mode)
zinit ice wait'0' lucid
zinit snippet OMZP::safe-paste

zinit ice wait'0' lucid
zinit snippet OMZP::extract

zinit ice wait'0' lucid
zinit snippet OMZP::copybuffer

zinit ice wait'0' lucid
zinit snippet OMZP::copypath

zinit ice wait'0' lucid
zinit snippet OMZP::copyfile

zinit ice wait'0' lucid
zinit snippet OMZP::dirhistory

zinit ice wait'0' lucid
zinit snippet OMZP::jsontools

# OMZ lib for some utilities
zinit ice wait'0' lucid
zinit snippet OMZL::clipboard.zsh

# ============================================================================
# COMPLETIONS (loaded in turbo mode)
# ============================================================================
zinit ice wait'1' lucid as'completion'
zinit snippet OMZP::docker/completions/_docker

zinit ice wait'1' lucid as'completion'
zinit snippet OMZP::docker-compose/_docker-compose

zinit ice wait'1' lucid as'completion'
zinit snippet OMZP::terraform/_terraform

zinit ice wait'1' lucid as'completion'
zinit snippet OMZP::pip/_pip

# Cached kubectl completions
if [[ ! -f ~/.zcompdump-kubectl ]] || [[ ~/.zcompdump-kubectl -ot $(which kubectl) ]]; then
  kubectl completion zsh > ~/.zcompdump-kubectl 2>/dev/null
fi
zinit ice wait'1' lucid
zinit snippet ~/.zcompdump-kubectl

# AWS completion (deferred)
zinit ice wait'1' lucid atload'
  complete -C "/usr/local/bin/aws_completer" aws
  complete -C "/usr/local/bin/aws_completer" awslocal
'
zinit light zdharma-continuum/null

# ============================================================================
# KUBE-PS1 SETTINGS (grayscale)
# ============================================================================
export KUBE_PS1_BINARY=kubectl
export KUBE_PS1_NS_ENABLE=true
export KUBE_PS1_PREFIX=""
export KUBE_PS1_SUFFIX=""
export KUBE_PS1_CTX_COLOR=""
export KUBE_PS1_NS_COLOR=""
export KUBE_PS1_SYMBOL_ENABLE=false

# ============================================================================
# SIMPLE GIT PROMPT (replaces oh-my-zsh git_super_status)
# ============================================================================
_git_prompt() {
  local branch=$(git symbolic-ref --short HEAD 2>/dev/null)
  [[ -z "$branch" ]] && return

  local status_flags=""
  local git_status=$(git status --porcelain 2>/dev/null)

  [[ -n $(echo "$git_status" | grep "^??") ]] && status_flags+="?"
  [[ -n $(echo "$git_status" | grep "^.M\|^.D") ]] && status_flags+="*"
  [[ -n $(echo "$git_status" | grep "^M\|^A\|^D\|^R") ]] && status_flags+="+"

  local ahead_behind=$(git rev-list --left-right --count HEAD...@{upstream} 2>/dev/null)
  if [[ -n "$ahead_behind" ]]; then
    local ahead=$(echo "$ahead_behind" | cut -f1)
    local behind=$(echo "$ahead_behind" | cut -f2)
    [[ "$ahead" -gt 0 ]] && status_flags+="${ahead}>"
    [[ "$behind" -gt 0 ]] && status_flags+="${behind}<"
  fi

  if [[ -n "$status_flags" ]]; then
    echo "[$branch|$status_flags]"
  else
    echo "[$branch]"
  fi
}

# ============================================================================
# LANGUAGE SETTINGS
# ============================================================================
# Ruby
export GEM_HOME="$HOME/.gem"

# Go
export GOPATH=$HOME/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

# Pyenv lazy-loading
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
pyenv() {
  unfunction pyenv 2>/dev/null
  eval "$(command pyenv init -)"
  pyenv "$@"
}

# NVM lazy-loading
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

# ============================================================================
# FZF LAZY-LOADING
# ============================================================================
_load_fzf() {
  unfunction fzf _fzf_complete 2>/dev/null
  # Remove keybinding wrappers
  [[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh
}

# Lazy wrapper for fzf
fzf() {
  _load_fzf
  fzf "$@"
}

# Load fzf keybindings on first Ctrl-R or Ctrl-T
_fzf_history_widget() {
  _load_fzf
  zle fzf-history-widget
}
_fzf_file_widget() {
  _load_fzf
  zle fzf-file-widget
}
zle -N _fzf_history_widget
zle -N _fzf_file_widget
bindkey '^R' _fzf_history_widget
bindkey '^T' _fzf_file_widget

# ============================================================================
# AUTOSUGGESTION SETTINGS
# ============================================================================
bindkey "^ " autosuggest-fetch
bindkey "^f" forward-char
bindkey "^w" forward-word
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# Alias expansion keybinding
bindkey "^Xe" _expand_alias

# ============================================================================
# ALIASES
# ============================================================================
[[ -f ~/.aliases/index ]] && source ~/.aliases/index

alias cat="bat --theme=GitHub --style=\"numbers,changes,header\""
alias bat="bat --theme=GitHub --style=\"numbers,changes,header\""
alias snowsql=/Applications/SnowSQL.app/Contents/MacOS/snowsql

# ============================================================================
# ENVIRONMENT
# ============================================================================
export LSP_USE_PLISTS=true
unset VIRTUAL_ENV

export PATH="$HOME/.local/bin:$PATH"

# pnpm
export PNPM_HOME="/Users/charles.baker/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
source ~/.sh_utility_functions.sh
. "$HOME/.local/share/../bin/env"

# ============================================================================
# PROMPT
# ============================================================================
setopt PROMPT_SUBST  # Enable command substitution in prompts

RPROMPT=''
export SHOW_AWS_PROMPT=false

# Cache git/pyenv info only on directory change
_last_pwd=""
_cached_git_root=""
_cached_python_version=""

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

  # Cache git root and python version (only update on directory change)
  if [[ "$PWD" != "$_last_pwd" ]]; then
    _last_pwd="$PWD"
    _cached_git_root=$(git rev-parse --show-toplevel 2>/dev/null | xargs basename 2>/dev/null)
    if [[ -f .python-version ]]; then
      _cached_python_version=$(< .python-version)
    else
      _cached_python_version=""
    fi
  fi
}

_kube_prompt() {
  local kp=$(kube_ps1 2>/dev/null)
  [[ -n "$kp" ]] && echo "$kp"$'\n'
}

_pyenv_prompt() {
  if [[ -n "$VIRTUAL_ENV" ]]; then
    echo "[venv:$(basename $VIRTUAL_ENV)] "
  elif [[ -n "$_cached_python_version" ]]; then
    echo "[py:$_cached_python_version] "
  fi
}

PROMPT=$'\n''%n@%m'$'\n''${_cached_git_root:-$(basename $PWD)}:$(_git_prompt)'$'\n''$(_pyenv_prompt)$timeprompt$(date +%d.%m.%y-%H:%M:%S)'$'\n''$(pwd)'$'\n'

# ============================================================================
# VTERM (Emacs)
# ============================================================================
if [[ "$INSIDE_EMACS" == 'vterm' ]] \
&& [[ -n ${EMACS_VTERM_PATH} ]] \
&& [[ -f ${EMACS_VTERM_PATH}/etc/emacs-vterm-zsh.sh ]]; then
  source ${EMACS_VTERM_PATH}/etc/emacs-vterm-zsh.sh
fi
