# shellcheck shell=bash
# Custom segment: gitmux — rich git status via gitmux binary

TMUX_POWERLINE_SEG_GITMUX_CFG="${XDG_CONFIG_HOME:-$HOME/.config}/gitmux/gitmux.cfg"

run_segment() {
	if ! command -v gitmux &>/dev/null; then
		return 1
	fi

	local pane_path
	pane_path=$(tmux display-message -p -F "#{pane_current_path}")

	if [ -z "$pane_path" ]; then
		return 1
	fi

	# Only output if we're in a git repo
	if ! git -C "$pane_path" rev-parse --git-dir &>/dev/null; then
		return 1
	fi

	if [ -f "$TMUX_POWERLINE_SEG_GITMUX_CFG" ]; then
		gitmux -cfg "$TMUX_POWERLINE_SEG_GITMUX_CFG" "$pane_path"
	else
		gitmux "$pane_path"
	fi
}
