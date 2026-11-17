# zsh-fzf-unified

A single managed source of truth for everything fzf inside zsh: shell
integration (Ctrl-T / Alt-C), history search (Ctrl-R), ripgrep live grep
(Ctrl-G), Tab completion (fzf-tab, vendored) and the Up/Down arrow policy —
one plugin instead of several loosely-coupled ones fighting over the same
keybindings.

## Why

- `zsh-fzf-history-search`, `fzf --zsh`, `fzf-tab` and assorted `zstyle`
  previews each bind overlapping keys. Whichever loads last wins, silently.
  This plugin owns all of them, in one file, with a defined precedence:
  **fzf-tab wins Tab; this plugin's widgets win Ctrl-R / Ctrl-G; arrows are
  hybrid.**
- Multiline history is a first-class case: entries are framed with NUL so
  embedded newlines never leak into picker rows, and Up/Down move the cursor
  between lines instead of walking history.
- Every fzf surface gets a preview (files, dirs, git refs, env vars,
  functions, aliases, processes, SSH hosts, grep matches).

## Features

| Key | Feature |
|-----|---------|
| `Ctrl-R` | fzf history search: deduplicated (newest kept), event number + date + time columns, multiline-safe, `Ctrl-Y` copies the command to the clipboard |
| `Up` / `Down` | Hybrid arrows: on a multiline buffer they move the cursor between lines (history only at the boundary); on a single-line buffer `Up` opens the Ctrl-R picker, `Down` walks history |
| `Ctrl-T` | File/dir picker with a Yazi-like content preview, toggled/resized with `Ctrl-/` |
| `Alt-C` | `cd` picker with a directory preview (git status + contents) |
| `Ctrl-G` | ripgrep live search: reloads on every keystroke, previews the match centred on its line, `Enter` puts `$EDITOR FILE +LINE` on the command line |
| `Tab` | fzf-tab (vendored, pinned) with per-context previews |
| `<` / `>` | fzf-tab group switching |

### Ctrl-R history search

- Multiline-safe: entries are framed with NUL; `fc -li` supplies ordering,
  event numbers and ISO8601 timestamps, `$history` supplies the exact
  multiline command text; ZLE restores the event via `vi-fetch-history`, so
  picked commands come back byte-for-byte.
- Deduplicated by command, newest occurrence kept.
- Colored columns (see [Configuration](#configuration)); fzf runs with
  `--ansi`, and escape codes never reach the clipboard or the buffer — the
  space-separated field layout `event date time command` survives intact.
- `Ctrl-Y` copies the highlighted command and closes the picker without
  inserting it (`pbcopy` / `xclip` / `wl-copy`, best available).

### Preview coverage (fzf-tab contexts)

| Context | Preview |
|---------|---------|
| `cd`, `z` | directory contents (`eza`, `ls`) |
| `env`, `export` | current variable value |
| `unset` | function definition (`whence -f`) or variable value |
| `unalias` | alias definition |
| `kill`, `killall`, `pkill` | process row (`ps`) or matching processes (`pgrep`) |
| `ssh` | resolved config (`ssh -G`) or DNS fallback |
| `git-checkout`, `git-diff`, `git-show`, `git-log` | commit with diff/stat |
| `o`, `oooconf` | subcommand/flag help |
| `-command-` | `tldr`, else `man` |
| everything else | generic file preview (see below) |

The generic file preview (`zsh-fzf-unified-preview`, also used by Ctrl-T and
Alt-C): directories get git status + contents (`eza`/`tree`/`ls`), symlinks
resolve with their target shown, images render via `kitten icat` (kitty,
ghostty) / `chafa` / `imgcat` (iTerm2), archives list via `7z`, text via
`bat` (capped at 500 lines), binaries get a hex dump. It also accepts
`FILENAME:LINENO` (used by Ctrl-G) to highlight and centre a line. Modeled
after `junegunn/fzf`'s `bin/fzf-preview.sh`.

## Requirements

- zsh, [fzf](https://github.com/junegunn/fzf) ≥ 0.48 (for `fzf --zsh`);
  without `fzf` the plugin is a no-op.
- Oh My Zsh for the plugin entry point (or source the plugin file directly).
- Optional, auto-detected: `fd` or `rg` (file sources), `eza`/`tree`,
  `bat`, `chafa`/`kitten`/`imgcat`, `7z`, `tldr`, `pbcopy`/`xclip`/`wl-copy`.

## Install (Oh My Zsh)

```sh
git clone https://github.com/<you>/zsh-fzf-unified \
  "${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-fzf-unified"
```

```zsh
# .zshrc
plugins=( ... zsh-fzf-unified )
```

Removing its predecessors is part of the deal: drop
`zsh-fzf-history-search` from `plugins=()`, any standalone `fzf-tab` source
line, and `fzf` shell-integration lines — this plugin replaces all of them.

## Configuration

Set these **before** the plugin loads (e.g. in a `.zshrc.d/*.zsh` file or
before `plugins=(...)` in `.zshrc`) — the plugin only fills unset variables.

### Behavior

| Variable | Default | Meaning |
|----------|---------|---------|
| `ZSH_FZF_HISTORY_SEARCH_BIND` | `^r` | history-search keybinding (declared for compatibility; Ctrl-R is bound in all keymaps) |
| `ZSH_FZF_HISTORY_SEARCH_FZF_ARGS` | `+s +m -x -e` | base fzf args for the picker |
| `ZSH_FZF_HISTORY_SEARCH_FZF_EXTRA_ARGS` | `--height=~5` | extra args; `~5` ≈ five rows |
| `ZSH_FZF_HISTORY_SEARCH_END_OF_LINE` | `''` | jump to end-of-line after accepting |
| `ZSH_FZF_HISTORY_SEARCH_REMOVE_DUPLICATES` | `1` | dedupe by command, newest kept |
| `ZSH_FZF_HISTORY_SEARCH_DATES_IN_SEARCH` | `1` | include `date time` in the row/query |
| `ZSH_FZF_HISTORY_SEARCH_FZF_QUERY_PREFIX` | `''` | fixed prefix prepended to the initial query |

### Colors

Ctrl-R column colors are SGR parameter strings (what goes between
`ESC[` and `m`). Set them to `''` to leave a field uncolored; unset fields
fall back to the defaults. 256-color values need the full `38;5;N` form —
a bare `N` outside 30–37/90–97 is an undefined parameter and silently
renders as plain text.

| Variable | Default | Field |
|----------|---------|-------|
| `ZFZ_HISTORY_COLOR_EVENT` | `33` (yellow) | event number |
| `ZFZ_HISTORY_COLOR_DATE` | `90` (bright black) | date `YYYY-MM-DD` |
| `ZFZ_HISTORY_COLOR_TIME` | `36` (cyan) | time `HH:MM` |
| `ZFZ_HISTORY_COLOR_COMMAND` | `''` (plain) | command text |

Examples:

```zsh
# Plain SGR codes
ZFZ_HISTORY_COLOR_EVENT='33'   ZFZ_HISTORY_COLOR_DATE='90'   ZFZ_HISTORY_COLOR_TIME='36'

# 256-color / combined attributes
ZFZ_HISTORY_COLOR_EVENT='1;38;5;208'   # bold orange

# Disable coloring entirely
ZFZ_HISTORY_COLOR_EVENT='' ZFZ_HISTORY_COLOR_DATE='' ZFZ_HISTORY_COLOR_TIME=''
```

A theme (e.g. a dotfiles repo) can own these by setting the variables in a
`.zshrc.d/30-fzf.zsh` file that loads before Oh My Zsh.

### Global fzf options

| Variable | Set to |
|----------|--------|
| `FZF_DEFAULT_OPTS` | consistent visual flags: `--info inline --border --pointer '▍' --marker '▍'` |
| `FZF_DEFAULT_COMMAND` | `fd --type f --hidden --follow --exclude .git`, else an `rg --files` equivalent |
| `FZF_CTRL_T_OPTS` | Ctrl-T: right preview (60%), `Ctrl-/` cycles right / bottom / hidden |
| `FZF_ALT_C_OPTS` | Alt-C: bottom preview (60%), same `Ctrl-/` cycle |
| `FZF_CTRL_R_OPTS` | `--bind 'enter:accept'` safety default |
| `FZF_RG_COMMAND` | the ripgrep command Ctrl-G reloads (default: columnized, line-numbered, smart-case, gitignore-respecting) |

## Layout

```
zsh-fzf-unified.plugin.zsh   # OMZ entry point (resolves plugin root)
zsh-fzf-unified.zsh          # all fzf logic: integration, Ctrl-R, arrows, Ctrl-G, fzf-tab styling
zsh-fzf-unified-preview      # shared content preview script (dirs/git, images, archives, text, binaries)
vendor/fzf-tab/              # Aloxaf/fzf-tab pinned to 24105b1
LICENSE                      # MIT
THIRD-PARTY.md               # vendored/ported upstream notices
```

## Updating vendored fzf-tab

```sh
curl -sL https://github.com/Aloxaf/fzf-tab/archive/<sha>.tar.gz | \
  tar xz --strip-components=1 -C vendor/fzf-tab --exclude='.git'
```

## Notes

- Precedence is explicit: `fzf --zsh` binds Tab and Ctrl-R first; fzf-tab
  (loaded after it) rebinds Tab; this plugin rebinds Ctrl-R and Ctrl-G in
  `emacs`/`viins`/`vicmd`; arrow bindings are the hybrid widgets.
- Re-sourcing the plugin (second keymap, manual `source`) is a no-op.
- Column colors are injected with `--ansi`; escape codes are stripped by fzf
  itself, so clipboard copy (`Ctrl-Y`) and the restored buffer stay clean.

## License

MIT — see [`LICENSE`](LICENSE). Vendored and ported components keep their own
copyright notices; see [`THIRD-PARTY.md`](THIRD-PARTY.md).
