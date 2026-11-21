# Ctrl-R History Search

`fzf_history_search` is ported from `joshskidmore/zsh-fzf-history-search` and extended to handle multiline commands, colored aligned columns, deduplication, and clipboard export cleanly.

## How It Works

1. **Ordering & timestamps from `fc -li -1 0`:** Lists history newest-first with event numbers and `YYYY-MM-DD HH:MM` timestamps. `SHARE_HISTORY` `*` suffixes on foreign events are stripped and continuation lines are skipped.
2. **Exact command text from `$history`:** Loads `zsh/parameter` (`p:history`) so `$history[$event]` yields the complete original command, including embedded newlines.
3. **NUL framing (`--read0`):** Each entry is emitted as `printf '%s\0'`, so multiline commands remain one row in fzf instead of splitting across picker lines.
4. **Deduplication:** When `ZSH_FZF_HISTORY_SEARCH_REMOVE_DUPLICATES` is non-empty (default `1`), each unique command is emitted once — keeping the newest occurrence because `fc -li` iterates newest-first.
5. **Aligned colored columns:**
   - Event numbers are right-aligned to the width of the newest (widest) event so the date column lines up without TAB gaps.
   - Colors use `--ansi` via [SGR column variables](/config/colors); fzf strips escape sequences from its output and from `{}` in `execute-silent`.
6. **Byte-for-byte restoration:** On accept, leading alignment spaces are trimmed, the event number is extracted, and ZLE executes `zle vi-fetch-history -n "$selected_event"` (followed by `zle end-of-line` if `ZSH_FZF_HISTORY_SEARCH_END_OF_LINE` is non-empty).

## Initial Query

If your command line already has text (`$#BUFFER > 0`), the picker starts with:

```zsh
-q "${ZSH_FZF_HISTORY_SEARCH_FZF_QUERY_PREFIX}${BUFFER}"
```

## Copying with `Ctrl-Y`

Pressing `Ctrl-Y` inside the `Ctrl-R` picker runs:

```sh
printf %s '{}' | sed 's/^ *//' | cut -d' ' -f4- | <clipboard_cmd>
```

and aborts the picker without modifying your current prompt buffer. Clipboard command selection checks:

1. `pbcopy` when `$OSTYPE` is `darwin*`
2. `xclip -selection clipboard`
3. `wl-copy`
4. fallback `cat >/dev/null`

::: info Safe default for `FZF_CTRL_R_OPTS`
The plugin exports `FZF_CTRL_R_OPTS="--bind 'enter:accept'"` so `Enter` only accepts into the command buffer and never executes immediately.
:::
