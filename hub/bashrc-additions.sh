# shellcheck shell=bash
# kb-hub shell additions (appended once by bootstrap-hub.sh; marker line)
alias e='emacsclient -t'
alias ei='emacsclient -t ~/kb/inbox.org'

# Interactive SSH sessions land in the persistent tmux session, so a
# dropped phone connection costs nothing — reconnect and resume.
# (Ubuntu's default .bashrc returns early for non-interactive shells,
# so scripted ssh commands never trigger this.)
if [ -z "$TMUX" ] && [ -n "$SSH_CONNECTION" ] && command -v tmux >/dev/null 2>&1; then
    tmux new-session -A -s main
fi
