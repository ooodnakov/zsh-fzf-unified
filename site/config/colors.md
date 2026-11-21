# Column Colors (SGR)

Ctrl-R column colors are **SGR parameter strings** — the sequence placed between `ESC[` and `m`.

Set any variable **before** loading the plugin (e.g. in `.zshrc.d/30-fzf.zsh` before Oh My Zsh loads). Set a variable to `''` to leave that field uncolored; unset variables fall back to defaults.

## Color Variables

| Variable | Default | Field |
|---|---|---|
| `ZFZ_HISTORY_COLOR_EVENT` | `33` (yellow) | Event number |
| `ZFZ_HISTORY_COLOR_DATE` | `90` (bright black) | Date (`YYYY-MM-DD`) |
| `ZFZ_HISTORY_COLOR_TIME` | `36` (cyan) | Time (`HH:MM`) |
| `ZFZ_HISTORY_COLOR_COMMAND` | `''` (plain) | Command text |

::: warning 256-color values require `38;5;N`
256-color codes must use the full `38;5;N` form (or `1;38;5;N` for bold). A bare number `N` outside `30–37` or `90–97` is an undefined SGR parameter and silently renders as plain text.
:::

## Examples

```zsh
# Plain SGR codes (default)
ZFZ_HISTORY_COLOR_EVENT='33'
ZFZ_HISTORY_COLOR_DATE='90'
ZFZ_HISTORY_COLOR_TIME='36'
ZFZ_HISTORY_COLOR_COMMAND=''

# 256-color / combined attributes
ZFZ_HISTORY_COLOR_EVENT='1;38;5;208'   # bold orange

# Disable coloring entirely
ZFZ_HISTORY_COLOR_EVENT=''
ZFZ_HISTORY_COLOR_DATE=''
ZFZ_HISTORY_COLOR_TIME=''
```

## Dotfiles Theme Ownership

A theme or dotfiles repository can own these colors by exporting or setting `ZFZ_HISTORY_COLOR_*` inside a drop-in file such as `.zshrc.d/30-fzf.zsh` that executes before Oh My Zsh sources `zsh-fzf-unified`.

Because `fzf` runs with `--ansi`, escape codes are stripped from `fzf` output and from `{}` in `--bind` actions — clipboard copy (`Ctrl-Y`) and the restored command buffer stay completely clean.
