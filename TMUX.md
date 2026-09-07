# Tmux Setup
    
## Terminal & Display

- **True color** with Ghostty support (`xterm-ghostty:Tc`)
- **Extended keys** (CSI-u) for Ctrl-Tab / Shift-Ctrl-Tab in Ghostty
- Powerline status bar drawn entirely in **ANSI slots**, so it follows the
  Emacs theme (see [Theme](#theme))
- Pane borders show index, title, and current command
- Panes take the terminal's own background (`bg=default`), so the page shows
  through rather than being painted over

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

The bar has **no palette of its own**. Every colour is an ANSI slot name, and
Emacs refits those slots to whatever theme is active — so the bar changes with
the editor instead of sitting on top of it.

### Why slots

A terminal's colour table holds 256 entries plus a default fg/bg, and only
**slots 0–15 are remappable**. Slots 16–255 are a fixed RGB cube and grey ramp,
and truecolor (`ESC[38;2;R;G;Bm`) names an exact colour and bypasses the table
altogether. This bar used to be written in hex and 256-cube indices
(`231`/`254`/`248`/`240`), which is why it stayed the same eight greys no matter
what the editor did.

`COLORTERM` is dropped under ghostel (see `.zshrc`) so programs emit slot
escapes rather than truecolor and stay remappable.

### The ladder

The four achromatic slots are fitted to *exact* WCAG contrasts against the page,
which makes them a prominence ladder rather than four arbitrary greys:

| rung | contrast vs page | role | was |
|---|---|---|---|
| `default` | 1.0 | the page itself | `#eeeeee` |
| `colour0` | 1.5 | wash | `#e4e4e4` |
| `colour8` | 3.0 | subtle | `#a8a8a8` |
| `colour15` | 5.5 | mid | `#808080` |
| `colour7` | 9.0 | body ink | `#585858` |

A pair's contrast is the **ratio of its two rungs**: `colour7` on `colour0` is
9.0/1.5 = 6.0. Keep text pairs at 3.0 or better. Chromatic slots are
deliberately unused — chrome encodes prominence here, it is not a stoplight.

### Where the fit lives

In [`chiply/.zetta.d`](https://github.com/chiply/.zetta.d):
`zetta-ghostel-apply-ansi-palette` in `modules/tools/ghostel.el`, with the rungs
in `zetta-ghostel-contrast-targets`. **That repo owns these numbers** — changing
a rung there restyles this bar. `docs/ansi-palette.md` there is the full
writeup.

It works outside Emacs too: the standalone Ghostty app is configured on
*Zenbones Light*, the same theme ghostel refits, so the bar reads as the same
palette in both hosts — fitted in one, raw in the other.

### Rules for editing

- **Segment rungs must step monotonically** away from the anchor on each side. A
  powerline wedge is drawn in the *previous* segment's background, so two
  neighbours on the same rung leave no visible seam. Half these segments come
  and go — gitmux hides when clean, `now_playing` when nothing plays, `vpn` when
  down — and monotonic is the arrangement where every pair that *can* end up
  adjacent still differs. Reordering or re-colouring means re-checking the
  dropout cases.
- **`tp_format inverse` is unusable** now the bar field is `default`. It emits
  `fg=$bg_color`, which resolves to the terminal's default *foreground* — dark
  ink on a dark pill. The active-window pill spells its two styles out instead.
- **`message-style` cannot be set in a sourced theme.** tmux-powerline's
  `main.tmux` overwrites it with the bar style, and TPM runs at the very bottom
  of `.tmux.conf`, so anything set earlier is gone before it is drawn. Set it
  *after* the `run .../tpm` line or not at all.
- **gitmux gets no field of its own.** It carries the most text and wants the
  full 9.0/5.5/3.0 spread rather than the compressed version a tinted field
  leaves, so it is drawn straight on the page.
- **fzf spells terminal-default `-1`**, not `default`. Its `hl`/`hl+` carry
  `bold` because there is no rung above `colour7` to spend on matched
  characters.

### Files

| file | what it draws |
|---|---|
| `.config/tmux-powerline/themes/tomorrow-light.sh` | status bar segments, window pills |
| `.tmux/themes/tomorrow-powerline.tmux` | pane borders, copy mode, popups, clock |
| `.config/gitmux/gitmux.cfg` | the git segment's three text rungs |
| `.config/tmux-powerline/config.sh` | k8s and vpn symbol colours |
| `.tmux.conf` | the fzf popup theme |

## Files

```
files/.tmux.conf                    # Main config
files/.tmux/themes/                 # Theme files
files/.config/tmux-powerline/       # Powerline segment config
files/.config/gitmux/gitmux.cfg     # Git segment styling
```
