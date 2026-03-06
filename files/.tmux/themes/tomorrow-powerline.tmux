# ============================================================================
# Tomorrow Light - Pane, Window & UI styles
# ============================================================================
# Status bar segments are handled by tmux-powerline.
# This file covers everything else: pane borders, window bg, messages, etc.
#
# Palette (Tomorrow Light):
#   bg        #ffffff
#   bg-alt    #efefef
#   bg-dim    #e0e0e0
#   fg        #4d4d4c
#   fg-dim    #8e908c (comment)
#   red       #c82829
#   orange    #f5871f
#   yellow    #eab700
#   green     #718c00
#   aqua      #3e999f
#   blue      #4271ae
#   purple    #8959a8
# ============================================================================

# -- Window styles -----------------------------------------------------------

setw -g window-style "bg=#f7f7f7"
setw -g window-active-style "bg=#ffffff"

# -- Pane borders ------------------------------------------------------------

set -g pane-border-style "fg=#d6d6d6"
set -g pane-active-border-style "fg=#4271ae"
set -g pane-border-status top
set -g pane-border-format " #[fg=#4271ae,bold]#{pane_index}#[default,fg=#8e908c] #{pane_title} #[fg=#d6d6d6]#{pane_current_command} "

# -- Message bar -------------------------------------------------------------

set -g message-style "bg=#4271ae,fg=#ffffff,bold"
set -g message-command-style "bg=#3e999f,fg=#ffffff,bold"

# -- Mode (copy mode highlight) ---------------------------------------------

set -g mode-style "bg=#4271ae,fg=#ffffff"
set -g copy-mode-current-match-style "bg=#f5871f,fg=#ffffff"
set -g copy-mode-match-style "bg=#eab700,fg=#4d4d4c"

# -- Clock -------------------------------------------------------------------

set -g clock-mode-colour "#4271ae"
set -g clock-mode-style 24
