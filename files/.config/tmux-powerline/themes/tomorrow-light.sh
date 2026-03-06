# shellcheck shell=bash
# ============================================================================
# Tomorrow Light theme for tmux-powerline
# ============================================================================
#
# 256-color mapping of the Tomorrow Light palette:
#   bg        #ffffff  →  231
#   bg-alt    #efefef  →  255
#   bg-dim    #e0e0e0  →  254
#   fg        #4d4d4c  →  239
#   fg-dim    #8e908c  →  245
#   red       #c82829  →  160
#   orange    #f5871f  →  208
#   yellow    #eab700  →  178
#   green     #718c00  →  64
#   aqua      #3e999f  →  73
#   blue      #4271ae  →  67
#   purple    #8959a8  →  133
# ============================================================================

if tp_patched_font_in_use; then
	TMUX_POWERLINE_SEPARATOR_LEFT_BOLD=""
	TMUX_POWERLINE_SEPARATOR_LEFT_THIN=""
	TMUX_POWERLINE_SEPARATOR_RIGHT_BOLD=""
	TMUX_POWERLINE_SEPARATOR_RIGHT_THIN=""
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
# Active window: blue pill with white text
if [ -z "$TMUX_POWERLINE_WINDOW_STATUS_CURRENT" ]; then
	TMUX_POWERLINE_WINDOW_STATUS_CURRENT=(
		"#[$(tp_format inverse)]"
		"$TMUX_POWERLINE_DEFAULT_LEFTSIDE_SEPARATOR"
		" #I "
		"$TMUX_POWERLINE_SEPARATOR_RIGHT_THIN"
		" #W "
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
		"  #I#{?window_flags,#F, } "
		"$TMUX_POWERLINE_SEPARATOR_RIGHT_THIN"
		" #W "
	)
fi

# -- Left status segments ---------------------------------------------------
# Format: "segment_name bg fg [separator] [sep_bg] [sep_fg] [spacing] [sep_disable]"

if [ -z "$TMUX_POWERLINE_LEFT_STATUS_SEGMENTS" ]; then
	TMUX_POWERLINE_LEFT_STATUS_SEGMENTS=(
		#                  bg   fg
		"tmux_session_info 67   231"                                              # blue bg, white text
		"mode_indicator    133  231"                                              # purple bg, white text
		"gitmux            254  239  default_separator no_sep_bg_color no_sep_fg_color no_spacing_disable separator_disable"  # gitmux handles its own colors
	)
fi

# -- Right status segments --------------------------------------------------

if [ -z "$TMUX_POWERLINE_RIGHT_STATUS_SEGMENTS" ]; then
	TMUX_POWERLINE_RIGHT_STATUS_SEGMENTS=(
		#                       bg   fg
		"pwd                    254  239"                                          # dim bg, dark text
		"now_playing            73   231"                                          # aqua bg, white text
		"battery                254  239"                                          # dim bg, dark text
		"weather                73   231"                                          # aqua bg, white text
		"date_day               64   231"                                          # green bg, white text
		"date                   64   231  ${TMUX_POWERLINE_SEPARATOR_LEFT_THIN}"   # green bg, thin sep
		"time                   67   231  ${TMUX_POWERLINE_SEPARATOR_LEFT_THIN}"   # blue bg, white text
	)
fi
