# ============================================================================
# Tomorrow Light - Pane, Window & UI styles
# ============================================================================
# Status bar segments are handled by tmux-powerline.
# This file covers everything else: pane borders, window bg, messages, etc.
#
# Palette (Grayscale):
#   bg        #ffffff
#   bg-alt    #efefef
#   bg-dim    #e0e0e0
#   fg        #4d4d4c
#   fg-dim    #8e908c
#   accent    #555555
#   mid       #888888
#   border    #d6d6d6
# ============================================================================

# -- Window styles -----------------------------------------------------------

setw -g window-style "bg=default"
setw -g window-active-style "bg=default"

# -- Pane borders ------------------------------------------------------------

set -g pane-border-style "fg=#d6d6d6"
set -g pane-active-border-style "fg=#555555"
set -g pane-border-status top
set -g pane-border-format " #[fg=#555555,bold]#{pane_index}#[default,fg=#8e908c] #{pane_title} #[fg=#d6d6d6]#{pane_current_command} #{?window_zoomed_flag,#[fg=#555555 bold] ZOOM ,}"

# -- Message bar -------------------------------------------------------------

set -g message-style "bg=#555555,fg=#ffffff,bold"
set -g message-command-style "bg=#888888,fg=#ffffff,bold"

# -- Mode (copy mode highlight) ---------------------------------------------

set -g mode-style "bg=#555555,fg=#ffffff,bold"
set -g copy-mode-current-match-style "bg=#333333,fg=#ffffff,bold"
set -g copy-mode-match-style "bg=#cccccc,fg=#4d4d4c"

# -- Popups ------------------------------------------------------------------

set -g popup-style "bg=default"
set -g popup-border-style "fg=#d6d6d6"
set -g popup-border-lines rounded

# -- Clock -------------------------------------------------------------------

set -g clock-mode-colour "#555555"
set -g clock-mode-style 24
