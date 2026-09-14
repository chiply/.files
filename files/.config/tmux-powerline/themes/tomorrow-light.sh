# shellcheck shell=bash
# ============================================================================
# Zetta ladder theme for tmux-powerline
# ============================================================================
#
# Segments name ANSI SLOTS, never 256-cube indices.  Slots 0-15 are the only
# remappable part of the terminal's colour table; Emacs refits them to the
# current brushup page on every theme change (see ghostel.el), so a bar
# written in slots follows the theme and a bar written in 231/254/240 -- the
# fixed grey ramp this file used to use -- cannot.  Same move as
# ~/.claude/themes/zetta.json, which is ansi:-only for exactly this reason.
#
# The four achromatic slots are fitted to EXACT contrasts against the page,
# which makes them a prominence ladder.  The old greys map onto it 1:1:
#
#   was        rung      contrast   role
#   #eeeeee    default      1.0     the page -- the bar's own field
#   #e4e4e4    colour0      1.5     wash: quiet segments
#   #a8a8a8    colour8      3.0     subtle
#   #808080    colour15     5.5     mid
#   #585858    colour7      9.0     body ink: the anchor segments
#
# A pair's contrast is the ratio of its rungs, so colour0-on-colour7 is
# 9.0/1.5 = 6.0.  Keep text pairs at 3.0 or better.
#
# NOTE: `tp_format inverse' is NOT usable here.  It emits fg=$bg_color, and
# with the field on `default' that resolves to the terminal's default
# FOREGROUND -- dark ink on a dark pill.  The active-window pill below
# spells its two styles out instead.
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

# The bar sits on the page itself, so it takes the theme's ground (and, in
# the standalone Ghostty app, its background-opacity) rather than painting
# over it.  Body text is the top rung.
TMUX_POWERLINE_DEFAULT_BACKGROUND_COLOR=${TMUX_POWERLINE_DEFAULT_BACKGROUND_COLOR:-'default'}
TMUX_POWERLINE_DEFAULT_FOREGROUND_COLOR=${TMUX_POWERLINE_DEFAULT_FOREGROUND_COLOR:-'colour7'}

TMUX_POWERLINE_DEFAULT_LEFTSIDE_SEPARATOR=${TMUX_POWERLINE_DEFAULT_LEFTSIDE_SEPARATOR:-$TMUX_POWERLINE_SEPARATOR_RIGHT_BOLD}
TMUX_POWERLINE_DEFAULT_RIGHTSIDE_SEPARATOR=${TMUX_POWERLINE_DEFAULT_RIGHTSIDE_SEPARATOR:-$TMUX_POWERLINE_SEPARATOR_LEFT_BOLD}

# -- Window status (tabs) ---------------------------------------------------
# Active window: body-ink pill, wash text (6.0).  Written out rather than
# via `tp_format inverse' -- see the NOTE above.
if [ -z "$TMUX_POWERLINE_WINDOW_STATUS_CURRENT" ]; then
    TMUX_POWERLINE_WINDOW_STATUS_CURRENT=(
        "#[fg=colour0,bg=colour7,nobold,noitalics,nounderscore]"
        "$TMUX_POWERLINE_DEFAULT_LEFTSIDE_SEPARATOR"
        " #I:#W "
        "#[fg=colour7,bg=default,nobold,noitalics,nounderscore]"
        "$TMUX_POWERLINE_DEFAULT_LEFTSIDE_SEPARATOR"
    )
fi

# Inactive windows: body ink straight on the page (9.0)
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

# -- Status segments ---------------------------------------------------------
# Format: "segment_name bg fg [separator] [sep_bg] [sep_fg] [spacing] [sep_disable]"
#
# The rungs step MONOTONICALLY away from the anchor on each side -- ink at the
# outer edge, page at the inner.  That is not decoration: a powerline wedge is
# drawn in the previous segment's background, so two neighbours on the same
# rung leave no visible seam.  Half of these segments come and go (gitmux
# hides itself when clean, now_playing when nothing is playing, vpn when
# down), and a monotonic ladder is the arrangement where every pair that CAN
# end up adjacent still differs.  Reordering or re-colouring a segment means
# re-checking the dropout cases.

if [ -z "$TMUX_POWERLINE_LEFT_STATUS_SEGMENTS" ]; then
    TMUX_POWERLINE_LEFT_STATUS_SEGMENTS=(
        #                      bg        fg
        "tmux_session_info     colour7   colour0"                                     # ink pill, wash text     (6.0)
        "mode_indicator        colour15  colour0"                                     # mid pill, wash text     (3.7)
        "gitmux                default   colour7  default_separator no_sep_bg_color no_sep_fg_color no_spacing_disable separator_disable"  # on the page: gitmux styles its own text and wants all three rungs
        "kubernetes_context    colour8   colour7"                                     # subtle field, ink text  (3.0)
        "vpn                   colour0   colour7  ${TMUX_POWERLINE_SEPARATOR_RIGHT_THIN}"  # wash field, ink text (6.0)
    )
fi

if [ -z "$TMUX_POWERLINE_RIGHT_STATUS_SEGMENTS" ]; then
    TMUX_POWERLINE_RIGHT_STATUS_SEGMENTS=(
        #                       bg        fg
        "pwd                    colour0   colour7"                                    # wash field, ink text    (6.0)
        "now_playing            colour8   colour7"                                    # subtle field, ink text  (3.0)
        "battery                colour15  colour0"                                    # mid field, wash text    (3.7)
        "hostname               colour7   colour0"                                    # ink pill, wash text     (6.0)
    )
fi
