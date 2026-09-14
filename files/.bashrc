[ -f ~/.fzf.bash ] && source ~/.fzf.bash



export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
command -v pyenv >/dev/null && eval "$(pyenv init -)"

# `unexport' is not a bash builtin; drop the variable instead
unset VIRTUAL_ENV

# every optional tool below is sourced only when it is installed
[ -f "$HOME/Library/Application Support/org.dystroy.broot/launcher/bash/br" ] && \
  source "$HOME/Library/Application Support/org.dystroy.broot/launcher/bash/br"
[ -f "$HOME/.config/broot/launcher/bash/br" ] && \
  source "$HOME/.config/broot/launcher/bash/br"
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"   # uv
