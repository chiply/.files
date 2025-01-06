[ -f ~/.fzf.bash ] && source ~/.fzf.bash



export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

unexport VIRTUAL_ENV


source /Users/charles.baker/Library/Application\ Support/org.dystroy.broot/launcher/bash/br

source /Users/charles.baker/.config/broot/launcher/bash/br

. "$HOME/.cargo/env"

. "$HOME/.local/share/../bin/env"
