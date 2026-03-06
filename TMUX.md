# Tmux Setup
    
## Terminal & Display

- **True color** with Ghostty support (`xterm-ghostty:Tc`)
- **Extended keys** (CSI-u) for Ctrl-Tab / Shift-Ctrl-Tab in Ghostty
- **Tomorrow Light** theme with powerline status bar
- Pane borders show index, title, and current command
- Inactive panes have a slightly dimmed background (`#f7f7f7` vs `#ffffff`)

## General Behavior

- Windows and panes indexed from 1
- Windows renumber on close, don't auto-rename
- Panes remain on exit (not destroyed)
- Killing a session switches to another instead of detaching
- Mouse enabled, vi copy mode (`v` to select, `y` to yank to clipboard)
- 50k line scrollback
- 10ms escape time

## Keybindings

All bindings use the default prefix (`C-b`) unless marked **no prefix**.

### Navigation

| Key                   | Action                           |
|-----------------------|----------------------------------|
| `h` / `j` / `k` / `l` | Select pane (vim-style)          |
| `M-Arrow`             | Select pane (no prefix)          |
| `S-Left` / `S-Right`  | Previous/next window (no prefix) |
| `C-Tab` / `C-S-Tab`   | Next/previous window (no prefix) |

### Panes & Windows

| Key                   | Action                        |
|-----------------------|-------------------------------|
| `\|`                  | Split horizontal (keeps cwd)  |
| `-`                   | Split vertical (keeps cwd)    |
| `c`                   | New window (keeps cwd)        |
| `H` / `J` / `K` / `L` | Resize pane by 5 (repeatable) |
| `>` / `<`             | Swap pane down/up             |

### Sessions

| Key   | Action                           |
|-------|----------------------------------|
| `S`   | Create/attach session by name    |
| `X`   | Kill session (with confirmation) |
| `C-s` | Choose session tree              |
| `T`   | Sesh picker (popup)              |
| `C-s` | Sesh picker (no prefix)          |

### Utility

| Key | Action            |
|-----|-------------------|
| `r` | Reload config     |
| `b` | Toggle status bar |

## Plugins

Managed by [TPM](https://github.com/tmux-plugins/tpm). Install with `prefix + I`, update with `prefix + U`.

| Plugin                         | Key                    | Description                                           |
|--------------------------------|------------------------|-------------------------------------------------------|
| **tmux-powerline**             | —                      | Powerline-style status bar                            |
| **tmux-yank**                  | `y` (copy mode)        | System clipboard integration                          |
| **tmux-resurrect**             | `prefix + C-s` / `C-r` | Save and restore sessions across restarts             |
| **tmux-continuum**             | —                      | Auto-saves sessions every 10 minutes                  |
| **tmux-thumbs**                | `prefix + f`           | Vimium-style hints to copy visible text               |
| **extrakto**                   | `prefix + Tab`         | fzf search through scrollback, insert or copy (`C-y`) |
| **tmux-fzf-url**               | `prefix + u`           | Find and open URLs from scrollback                    |
| **tmux-fzf**                   | `prefix + F`           | fzf menus for sessions, windows, panes, and commands  |
| **tmux-nerd-font-window-name** | —                      | Nerd font icons in window names                       |
| **tmux-open**                  | `o` / `S` (copy mode)  | Open highlighted file or Google search selection      |
| **tmux-fuzzback**              | `prefix + /`           | fzf fuzzy search through scrollback buffer            |
| **tmux-notify**                | —                      | Desktop notification when a long command finishes     |
| **tmux-command-palette**       | —                      | Searchable command palette (prefix and root tables)   |
| **tmux-cht-sh**                | —                      | cht.sh cheatsheet lookup                              |
| **sesh**                       | `C-s` / `prefix + T`   | Smart session manager with fzf picker                 |

## Theme

Tomorrow Light palette with powerline segments. Defined in two files:

- `~/.tmux/themes/tomorrow-powerline.tmux` — pane borders, window styles, message bar, copy mode highlights
- `~/.config/tmux-powerline/` — powerline segment configuration

## Files

```
files/.tmux.conf                    # Main config
files/.tmux/themes/                 # Theme files
files/.config/tmux-powerline/       # Powerline segment config
```
