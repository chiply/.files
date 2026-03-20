# shellcheck shell=bash
# ============================================================================
# Tomorrow Light theme for tmux-powerline
# ============================================================================
#
# 256-color grayscale palette:
#   bg        #ffffff  →  231
#   bg-alt    #efefef  →  255
#   bg-dim    #e0e0e0  →  254
#   fg        #4d4d4c  →  239
#   fg-dim    #8e908c  →  245
#   dark      #555555  →  240
#   mid       #888888  →  244
#   mid-light #aaaaaa  →  248
# ============================================================================

if tp_patched_font_in_use; then
	TMUX_POWERLINE_SEPARATOR_LEFT_BOLD=" "
	TMUX_POWERLINE_SEPARATOR_LEFT_THIN=" "
	TMUX_POWERLINE_SEPARATOR_RIGHT_BOLD=" "
	TMUX_POWERLINE_SEPARATOR_RIGHT_THIN=" "
else
	TMUX_POWERLINE_SEPARATOR_LEFT_BOLD="◀"
	TMUX_POWERLINE_SEPARATOR_LEFT_THIN="❮"
	TMUX_POWERLINE_SEPARATOR_RIGHT_BOLD="▶"
	TMUX_POWERLINE_SEPARATOR_RIGHT_THIN="❯"
fi

# Light background, dark foreground
TMUX_POWERLINE_DEFAULT_BACKGROUND_COLOR=${TMUX_POWERLINE_DEFAULT_BACKGROUND_COLOR:-'255'}
TMUX_POWERLINE_DEFAULT_FOREGROUND_COLOR=${TMUX_POWERLINE_DEFAULT_FOREGROUND_COLOR:-'239'}

TMUX_POWERLINE_DEFAULT_LEFTSIDE_SEPARATOR=${TMUX_POWERLINE_DEFAULT_LEFTSIDE_SEPARATOR:-$TMUX_POWERLINE_SEPARATOR_RIGHT_BOLD}
TMUX_POWERLINE_DEFAULT_RIGHTSIDE_SEPARATOR=${TMUX_POWERLINE_DEFAULT_RIGHTSIDE_SEPARATOR:-$TMUX_POWERLINE_SEPARATOR_LEFT_BOLD}

# -- Window status (tabs) ---------------------------------------------------
# Active window: dark gray pill with white text
if [ -z "$TMUX_POWERLINE_WINDOW_STATUS_CURRENT" ]; then
	TMUX_POWERLINE_WINDOW_STATUS_CURRENT=(
		"#[$(tp_format inverse)]"
		"$TMUX_POWERLINE_DEFAULT_LEFTSIDE_SEPARATOR"
		" #I:#W "
		"#[$(tp_format regular)]"
		"$TMUX_POWERLINE_DEFAULT_LEFTSIDE_SEPARATOR"
	)
fi

# Inactive windows: muted text
if [ -z "$TMUX_POWERLINE_WINDOW_STATUS_STYLE" ]; then
	TMUX_POWERLINE_WINDOW_STATUS_STYLE=(
		"$(tp_format regular)"
	)
fi

if [ -z "$TMUX_POWERLINE_WINDOW_STATUS_FORMAT" ]; then
	TMUX_POWERLINE_WINDOW_STATUS_FORMAT=(
		"#[$(tp_format regular)]"
		"  #I#{?window_flags,#F,}:#W "
	)
fi

# -- Left status segments ---------------------------------------------------
# Format: "segment_name bg fg [separator] [sep_bg] [sep_fg] [spacing] [sep_disable]"

if [ -z "$TMUX_POWERLINE_LEFT_STATUS_SEGMENTS" ]; then
	TMUX_POWERLINE_LEFT_STATUS_SEGMENTS=(
		#                      bg   fg
		"tmux_session_info     240  231"                                              # dark gray bg, white text
		"mode_indicator        244  231"                                              # mid gray bg, white text
		"gitmux                254  239  default_separator no_sep_bg_color no_sep_fg_color no_spacing_disable separator_disable"  # gitmux handles its own colors
		"kubernetes_context    248  239"                                              # mid-light gray bg, dark text
		"vpn                   254  239  ${TMUX_POWERLINE_SEPARATOR_RIGHT_THIN}"      # light gray bg, dark text
	)
fi

# -- Right status segments --------------------------------------------------

if [ -z "$TMUX_POWERLINE_RIGHT_STATUS_SEGMENTS" ]; then
	TMUX_POWERLINE_RIGHT_STATUS_SEGMENTS=(
		#                       bg   fg
		"pwd                    254  239"                                          # light gray bg, dark text
		"now_playing            248  239"                                          # mid-light gray bg, dark text
		"battery                254  239"                                          # light gray bg, dark text
		"hostname               240  231"                                          # dark gray bg, white text
	)
fi
