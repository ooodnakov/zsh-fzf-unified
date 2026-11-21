# Keybindings Cheatsheet

Bindings for `Ctrl-R`, `Ctrl-G`, and `Up`/`Down` are installed explicitly across `emacs`, `viins`, and `vicmd` keymaps.

## Top-Level Bindings

| Key | Widget / Surface | Behavior |
|---|---|---|
| `Ctrl-R` | `fzf_history_search` | Open deduplicated, multiline-safe fzf history picker |
| `Up` | `zfz_up` | On a multiline buffer (`BUFFER` contains `\n`), move cursor up (`up-line-or-history`); on a single-line buffer, open the `Ctrl-R` history picker |
| `Down` | `down-line-or-history` | On a multiline buffer, move cursor down between lines before walking history at the bottom boundary |
| `Ctrl-T` | `fzf --zsh` file widget | Pick files/dirs with right-hand preview (`60%`) |
| `Alt-C` | `fzf --zsh` `cd` widget | Pick directories with bottom preview (`60%`) |
| `Ctrl-G` | `zfz_rg` | Interactive ripgrep live search; `Enter` puts `$EDITOR FILE +LINE` into the command buffer |
| `Tab` | `fzf-tab` | Context-aware completion picker |
| `<` / `>` | `fzf-tab` | Switch completion groups (`switch-group`) |

## Inside Pickers

| Surface | Key | Action |
|---|---|---|
| `Ctrl-R` history | `Enter` | Accept entry and fetch exact history event via `vi-fetch-history` |
| `Ctrl-R` history | `Ctrl-Y` | Copy command (without event/date/time prefix or ANSI escapes) to clipboard and abort picker |
| `Ctrl-T` files | `Ctrl-/` | Cycle preview window: right `60%` → bottom `60%` → hidden |
| `Alt-C` directories | `Ctrl-/` | Cycle preview window: bottom `60%` → hidden |
| `Tab` (`fzf-tab`) | `Tab` / `Shift-Tab` | Move down / up (`tab:down,btab:up`) |
| `Tab` (`fzf-tab`) | `Alt-S` | Toggle selection (`alt-s:toggle`) |
| `Ctrl-G` (`rg`) | `Enter` | Insert `${EDITOR:-vim} FILE +LINE` on the command line |

## `fzf-tab` Default fzf Bindings

The plugin sets `zstyle ':fzf-tab:*' fzf-bindings-default`:

```txt
tab:down,btab:up,change:top,alt-s:toggle,bspace:backward-delete-char/eof,ctrl-h:backward-delete-char/eof
```
