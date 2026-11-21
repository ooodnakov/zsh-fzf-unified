# Behavior & History Options

All configuration variables use zsh's `: ${VAR:=default}` pattern, meaning **only unset variables are filled in by the plugin**.

Set these **before** `zsh-fzf-unified` loads — for example in a `.zshrc.d/*.zsh` snippet or before `plugins=(...)` in `~/.zshrc`.

## History Search Variables

| Variable | Default | Meaning |
|---|---|---|
| `ZSH_FZF_HISTORY_SEARCH_BIND` | `^r` | History-search keybinding (declared for compatibility; `Ctrl-R` is bound in `emacs`, `viins`, and `vicmd`) |
| `ZSH_FZF_HISTORY_SEARCH_FZF_ARGS` | `+s +m -x -e` | Base `fzf` flags passed to the history picker |
| `ZSH_FZF_HISTORY_SEARCH_FZF_EXTRA_ARGS` | `--height=~5` | Extra `fzf` flags (`~5` adapts height to roughly five rows) |
| `ZSH_FZF_HISTORY_SEARCH_END_OF_LINE` | `''` | When non-empty, moves cursor to end-of-line (`zle end-of-line`) after accepting |
| `ZSH_FZF_HISTORY_SEARCH_EVENT_NUMBERS` | `1` | Declared for compatibility with `zsh-fzf-history-search` |
| `ZSH_FZF_HISTORY_SEARCH_DATES_IN_SEARCH` | `1` | Include `date` and `time` columns in the display and searchable text |
| `ZSH_FZF_HISTORY_SEARCH_REMOVE_DUPLICATES` | `1` | Deduplicate by command text, keeping only the newest occurrence |
| `ZSH_FZF_HISTORY_SEARCH_FZF_QUERY_PREFIX` | `''` | Fixed prefix prepended to `$BUFFER` when opening the picker on a non-empty prompt |

## Example

```zsh
# Before plugins=( ... zsh-fzf-unified )
ZSH_FZF_HISTORY_SEARCH_FZF_EXTRA_ARGS='--height=40% --layout=reverse'
ZSH_FZF_HISTORY_SEARCH_END_OF_LINE=1
ZSH_FZF_HISTORY_SEARCH_REMOVE_DUPLICATES=1
```
