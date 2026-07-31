#source ~/.localsecrets
#source ~/.tokens

# History
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY          # share history across tmux panes/sessions
setopt APPEND_HISTORY         # append rather than overwrite
setopt INC_APPEND_HISTORY     # write after each command, not on exit
setopt HIST_IGNORE_ALL_DUPS   # deduplicate
setopt HIST_REDUCE_BLANKS     # trim whitespace

# disable flow control so C-s is available for keybinding
stty -ixon

# this script assumes things have already been bootstrapped
export PATH=$HOME/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/local/sbin:$PATH

# ============================================================================
# IRIS (IntelliSense-style completion overlay, https://github.com/versenilvis/IRIS)
# ============================================================================
# Opt-in per session: `i` (or `iris`) enters an IRIS-wrapped shell, `exit` /
# C-d leaves it. Set IRIS_AUTO=1 (e.g. in ~/.zshenv) to make every new
# terminal an IRIS session instead. Config: ~/.config/iris/config.toml.
# While inside IRIS, it owns Tab / Enter / arrows / C-r; other keys pass
# through to zsh, and zsh-autosuggestions is skipped (see plugins below) so
# its ghost text doesn't fight with IRIS's.
if command -v iris >/dev/null 2>&1; then
  alias i="iris"

  # Shells in tmux panes inherit IRIS_* from an enclosing IRIS session, but
  # IRIS can't see through the tmux server — drop the stale markers.
  # (Mirrors the upstream `iris init zsh` hook.)
  if [[ -n "$TMUX" && -n "$IRIS_PID" ]]; then
    if ps -o comm= -p $PPID 2>/dev/null | grep -q "tmux"; then
      unset IRIS_PID IRIS_IS_CHILD IRIS_FD
    fi
  fi

  # Optional autostart (placed before zinit so nothing is initialized twice)
  if [[ "$IRIS_AUTO" == "1" && -z "$IRIS_PID" && -z "$IRIS_RESCUE" \
        && -z "$INSIDE_EMACS" && $- == *i* ]]; then
    export IRIS_ACTIVE_SHELL="zsh"
    exec iris
  fi

  # Inside an IRIS session: stream line buffer / cwd / exit codes to IRIS
  # over its fd so suggestions track the real zsh state.
  # (Mirrors the upstream `iris init zsh` hook.)
  if [[ -n "$IRIS_PID" && -n "$IRIS_FD" ]]; then
    _iris_send_lbuffer() {
      print -u $IRIS_FD -N -r -- "$LBUFFER" 2>/dev/null
    }
    _iris_sync_cwd() {
      print -u $IRIS_FD -N -r -- "IRIS_CWD:$PWD" 2>/dev/null
    }
    _iris_precmd() {
      local iris_exit_code=$?
      _iris_sync_cwd
      print -u $IRIS_FD -N -r -- "IRIS_CMD_STOP:$iris_exit_code" 2>/dev/null
    }
    _iris_preexec() {
      print -u $IRIS_FD -N -r -- "IRIS_CMD_START" 2>/dev/null
    }
    autoload -Uz add-zle-hook-widget
    autoload -Uz add-zsh-hook
    add-zle-hook-widget line-pre-redraw _iris_send_lbuffer
    add-zsh-hook precmd _iris_precmd
    add-zsh-hook preexec _iris_preexec
    add-zsh-hook chpwd _iris_sync_cwd
  fi
fi

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
# BANNER (random ASCII art on shell start)
# ============================================================================
_banner_dir="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/banner"
if [[ -d "$_banner_dir" ]]; then
  _banner_file=$(find -L "$_banner_dir" -type f -name '*.asc' | shuf -n 1)
  [[ -n "$_banner_file" ]] && cat "$_banner_file"
fi

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
  zstyle ":completion:*" list-colors "${(s.:.)LS_COLORS}"

  # fzf-tab settings
  zstyle ":fzf-tab:*" fzf-flags --color=fg:#4d4d4c,bg:#ffffff,hl:#555555,fg+:#1a1a1a,bg+:#e8e8e8,hl+:#333333,info:#888888,prompt:#555555,pointer:#333333,marker:#555555,spinner:#888888,header:#8e908c,border:#d6d6d6
  zstyle ":fzf-tab:complete:cd:*" fzf-preview "eza --icons=auto -1 --color=always \$realpath"
  zstyle ":fzf-tab:complete:ls:*" fzf-preview "eza --icons=auto -1 --color=always \$realpath"
  zstyle ":fzf-tab:complete:cat:*" fzf-preview "bat --theme=GitHub --style=numbers --color=always --line-range :200 \$realpath 2>/dev/null"
  zstyle ":fzf-tab:complete:bat:*" fzf-preview "bat --theme=GitHub --style=numbers --color=always --line-range :200 \$realpath 2>/dev/null"
  zstyle ":fzf-tab:complete:vim:*" fzf-preview "bat --theme=GitHub --style=numbers --color=always --line-range :200 \$realpath 2>/dev/null"
  zstyle ":fzf-tab:complete:export:*" fzf-preview "echo \$word"
  zstyle ":fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*" fzf-preview "echo \${(P)word}"
'
zinit light zdharma-continuum/null

# fzf-tab (must load after compinit)
zinit ice wait'0' lucid
zinit light Aloxaf/fzf-tab

# zoxide (must init after compinit for Space-Tab interactive picker)
zinit ice wait'0' lucid atload'eval "$(zoxide init zsh --cmd cd)"'
zinit light zdharma-continuum/null

# ============================================================================
# PLUGINS (loaded with turbo mode - after prompt shows)
# ============================================================================
# Essential plugins - load slightly after prompt
# (autosuggestions skipped inside IRIS sessions: doubled ghost text)
if [[ -z "$IRIS_PID" ]]; then
  zinit ice wait'0' lucid
  zinit light zsh-users/zsh-autosuggestions
fi

zinit ice wait'0' lucid
zinit light zsh-users/zsh-syntax-highlighting

zinit ice wait'0' lucid
zinit light Automaat/zsh-clean-history

zinit ice wait'0' lucid
zinit light olets/zsh-abbr

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

# kubectx/kubens completions
zinit ice wait'1' lucid as'completion'
zinit snippet https://raw.githubusercontent.com/ahmetb/kubectx/master/completion/_kubectx.zsh

zinit ice wait'1' lucid as'completion'
zinit snippet https://raw.githubusercontent.com/ahmetb/kubectx/master/completion/_kubens.zsh

# stern completions (cached)
if [[ ! -f ~/.zcompdump-stern ]] || [[ -x $(which stern) && ~/.zcompdump-stern -ot $(which stern) ]]; then
  stern --completion zsh > ~/.zcompdump-stern 2>/dev/null
fi
zinit ice wait'1' lucid
zinit snippet ~/.zcompdump-stern

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
export NVM_DIR="$HOME/.nvm"
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
# FZF
# ============================================================================
export FZF_DEFAULT_OPTS="
  --color=fg:#4d4d4c,bg:#ffffff,hl:#555555
  --color=fg+:#1a1a1a,bg+:#e8e8e8,hl+:#333333
  --color=info:#888888,prompt:#555555,pointer:#333333
  --color=marker:#555555,spinner:#888888,header:#8e908c
  --color=border:#d6d6d6,gutter:#ffffff,scrollbar:#d6d6d6
  --color=separator:#e0e0e0
  --border=rounded

  --margin=0,1
  --padding=0,1
  --info=inline-right
  --separator='─'
  --scrollbar='│'
  --ellipsis='…'
  --highlight-line
  --prompt='▸ '
  --pointer='▸'
  --marker='●'
"

export FZF_CTRL_T_OPTS="
  --preview='bat --color=always --style=numbers --line-range=:200 {} 2>/dev/null || ls -la {} 2>/dev/null'
  --preview-window='right:50%:border-left'
"

export FZF_ALT_C_OPTS="
  --preview='ls -la {} 2>/dev/null'
  --preview-window='right:40%:border-left'
"

# ============================================================================
# FZF LAZY-LOADING
# ============================================================================
_load_fzf() {
  unfunction fzf _fzf_complete 2>/dev/null
  # Remove keybinding wrappers
  [[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh
  # fzf --zsh rebinds ^R to fzf-history-widget; restore atuin
  bindkey '^R' atuin-search 2>/dev/null
}

# Lazy wrapper for fzf
fzf() {
  _load_fzf
  fzf "$@"
}

# Load fzf keybindings on first Ctrl-T
_fzf_file_widget() {
  _load_fzf
  zle fzf-file-widget
}
zle -N _fzf_file_widget
# ^R now handled by atuin (see atuin init below)
# ^T now handled by television (see tv init below)

# Edit command line in $EDITOR
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line

# ============================================================================
# AUTOSUGGESTION SETTINGS
# ============================================================================
bindkey "^ " autosuggest-fetch
bindkey "^f" forward-char
bindkey "^w" forward-word
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# Alias expansion keybinding
bindkey "^Xe" _expand_alias

# Ctrl-Backspace → backward-kill-word
bindkey '^H' backward-kill-word

# C-s → sesh picker (in tmux, handled by tmux directly; this is fallback outside tmux)
_sesh_picker() {
  zle -I
  local session
  session=$(sesh list -t -c -z 2>/dev/null | fzf --height 40% --reverse --border-label ' sesh ' --border --prompt '⚡  ')
  zle -R
  if [[ -n "$session" ]]; then
    BUFFER="sesh connect \"$session\""
    zle accept-line
  else
    zle reset-prompt
  fi
}
zle -N _sesh_picker
bindkey '^s' _sesh_picker

# ============================================================================
# ALIASES
# ============================================================================
[[ -f ~/.aliases/index ]] && source ~/.aliases/index

# Colorized man pages via bat
export MANPAGER="sh -c 'col -bx | bat -l man -p --theme=GitHub'"

alias ls="eza --icons=auto"
alias cat="bat --theme=GitHub --style=\"numbers,changes,header\""
alias bat="bat --theme=GitHub --style=\"numbers,changes,header\""
[ -x /Applications/SnowSQL.app/Contents/MacOS/snowsql ] && alias snowsql=/Applications/SnowSQL.app/Contents/MacOS/snowsql

# Kubernetes aliases
alias kctx="kubectx"
alias kns="kubens"
alias kubectl="kubecolor"
alias kneat="kubectl-neat"

# tmuxinator inside vterm (nested tmux, bypasses outer session)
alias mux='TMUX= tmuxinator start'

# ============================================================================
# ENVIRONMENT
# ============================================================================
export LSP_USE_PLISTS=true
unset VIRTUAL_ENV

export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$HOME/.local/bin:$PATH"

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
source ~/.sh_utility_functions.sh

# Atuin (shell history) - takes over C-r, keeps up-arrow as normal
eval "$(atuin init zsh --disable-up-arrow)"

# Television (fuzzy finder) - smart autocomplete on C-t (deferred after compinit)
zinit ice wait'1' lucid atload'eval "$(tv init zsh)"'
zinit light zdharma-continuum/null
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

# --- Prompt switching: "classic" (custom) vs "starship" ---
# Set PROMPT_STYLE in your environment or .zshenv to override default.
# Toggle at runtime with: prompt-toggle
PROMPT_STYLE="${PROMPT_STYLE:-starship}"

_apply_classic_prompt() {
  PROMPT=$'\n''${IRIS_PID:+[iris] }%n@%m'$'\n''${_cached_git_root:-$(basename $PWD)}:$(_git_prompt)'$'\n''$(_pyenv_prompt)$timeprompt$(date +%d.%m.%y-%H:%M:%S)'$'\n''$(pwd)'$'\n'
}

_apply_starship_prompt() {
  eval "$(starship init zsh)"
}

prompt-toggle() {
  if [[ "$PROMPT_STYLE" == "starship" ]]; then
    PROMPT_STYLE="classic"
    _apply_classic_prompt
    echo "Switched to classic prompt"
  else
    PROMPT_STYLE="starship"
    _apply_starship_prompt
    echo "Switched to starship prompt"
  fi
}

if [[ "$PROMPT_STYLE" == "starship" ]]; then
  _apply_starship_prompt
else
  _apply_classic_prompt
fi

# ============================================================================
# VTERM (Emacs)
# ============================================================================
if [[ "$INSIDE_EMACS" == 'vterm' ]] \
&& [[ -n ${EMACS_VTERM_PATH} ]] \
&& [[ -f ${EMACS_VTERM_PATH}/etc/emacs-vterm-zsh.sh ]]; then
  source ${EMACS_VTERM_PATH}/etc/emacs-vterm-zsh.sh
fi
