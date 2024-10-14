vterm_printf(){
    if [ -n "$TMUX" ]; then
        # Tell tmux to pass the escape sequences through
        # (Source: http://permalink.gmane.org/gmane.comp.terminal-emulators.tmux.user/1324)
        printf "\ePtmux;\e\e]%s\007\e\\" "$1"
    elif [ "${TERM%%-*}" = "screen" ]; then
        # GNU screen (screen, screen-256color, screen-256color-bce)
        printf "\eP\e]%s\007\e\\" "$1"
    else
        printf "\e]%s\e\\" "$1"
    fi
}

export -f vterm_printf
vterm_prompt_end(){
    vterm_printf "51;A$(whoami)@$(hostname):$(pwd)"
}
PS1=$PS1'\[$(vterm_prompt_end)\]'



export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"


unexport VIRTUAL_ENV

export LSP_USE_PLISTS=true

source /Users/charles.baker/Library/Application\ Support/org.dystroy.broot/launcher/bash/br

source /Users/charles.baker/.config/broot/launcher/bash/br

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/charles.baker/anaconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/charles.baker/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/charles.baker/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/charles.baker/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<


. "$HOME/.cargo/env"
