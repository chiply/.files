# ============================================================================
# Zetta ladder - Pane, Window & UI styles
# ============================================================================
# Status bar segments are handled by tmux-powerline.
# This file covers everything else: pane borders, window bg, messages, etc.
#
# Every colour here is an ANSI SLOT, never a hex value.  Slots 0-15 are the
# only part of the terminal's colour table that is remappable, and Emacs
# refits them to the current brushup page on every theme change
# (`zetta-ghostel-apply-ansi-palette', see modules/tools/ghostel.el).  Hex --
# and the 16-255 cube, which is just as fixed -- pins tmux to one theme and
# is why this bar used to sit on the page like a decal.  This is the same
# move as ~/.claude/themes/zetta.json, which is ansi:-only for the reason.
#
# The four achromatic slots are fitted to EXACT WCAG contrasts against the
# page, so they are a prominence ladder rather than four greys:
#
#   default   1.0   the page itself
#   colour0   1.5   a wash, barely off the page
#   colour8   3.0   subtle -- comment weight
#   colour15  5.5   mid
#   colour7   9.0   body ink, the strongest step
#
# Read a pair's contrast as the ratio of its two rungs: colour7 on colour0
# is 9.0/1.5 = 6.0.  Anything below ~3 is decoration, not text.
#
# Chromatic slots are deliberately unused: chrome encodes prominence on the
# ink ladder here, it is not a stoplight.
# ============================================================================

# -- Window styles -----------------------------------------------------------

setw -g window-style "bg=default"
setw -g window-active-style "bg=default"

# -- Pane borders ------------------------------------------------------------

set -g pane-border-style "fg=colour0"
set -g pane-active-border-style "fg=colour7"
set -g pane-border-status top
set -g pane-border-format " #[fg=colour7,bold]#{pane_index}#[default,fg=colour8] #{pane_title} #[fg=colour0]#{pane_current_command} #{?window_zoomed_flag,#[fg=colour7 bold] ZOOM ,}"

# -- Message bar -------------------------------------------------------------
#
# Not set here.  tmux-powerline's main.tmux does
#
#     tmux set-option -g message-style "$TMUX_POWERLINE_STATUS_STYLE"
#
# and TPM runs at the BOTTOM of ~/.tmux.conf, long after this file is
# sourced, so anything set here is overwritten before it is ever drawn.
# (The old "bg=#555555,fg=#ffffff,bold" here had been dead for the same
# reason.)  The message bar therefore inherits the bar's own style,
# fg=colour7 on the page, which is on the ladder already.  To reclaim it as
# an inverse pill, set it AFTER the `run .../tpm' line, not here.

# -- Mode (copy mode highlight) ---------------------------------------------
#
# Three rungs, so the match you are ON stays apart from the selection and
# from the matches you are not on.  The old palette spent #555555 on the
# selection and #333333 on the current match, two steps that the fitted
# ladder has no room to keep apart at the top; taking the selection down to
# mid buys the distinction back.

set -g mode-style "bg=colour15,fg=colour0,bold"
set -g copy-mode-current-match-style "bg=colour7,fg=colour0,bold"
set -g copy-mode-match-style "bg=colour0,fg=colour7"

# -- Popups ------------------------------------------------------------------

set -g popup-style "bg=default"
set -g popup-border-style "fg=colour0"
set -g popup-border-lines rounded

# -- Clock -------------------------------------------------------------------

set -g clock-mode-colour "colour7"
set -g clock-mode-style 24
