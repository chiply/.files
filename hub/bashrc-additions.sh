# shellcheck shell=bash
# kb-hub shell config. Deployed by bootstrap-hub.sh to ~/.kb-hub-shell.sh
# and sourced from ~/.bashrc — edit HERE and hub-deploy; hub-side edits
# get overwritten.
alias e='emacsclient -t'
alias ei='emacsclient -t ~/kb/inbox.org'

# manual readwise refresh: trigger the sync, wait out the run, show result
alias rw='systemctl --user start readwise-sync.service && sleep 9 && journalctl --user -u readwise-sync.service -n 2 --no-pager -o cat'

# manual llm-convo queue drain: converts queued ChatGPT share links now
alias lc='~/.local/bin/llm_convo_sync.py'

# Interactive SSH sessions land in the persistent tmux session, so a
# dropped phone connection costs nothing — reconnect and resume.
# (Ubuntu's default .bashrc returns early for non-interactive shells,
# so scripted ssh commands never trigger this.)
if [ -z "$TMUX" ] && [ -n "$SSH_CONNECTION" ] && command -v tmux >/dev/null 2>&1; then
    tmux new-session -A -s main
fi
