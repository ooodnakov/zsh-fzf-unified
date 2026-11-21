# Previews & fzf-tab Contexts

`zsh-fzf-unified` provides previews across two layers: per-context `zstyle ':fzf-tab:complete:...'` rules for `Tab` completion, and the standalone `zsh-fzf-unified-preview` script shared by `Ctrl-T`, `Alt-C`, and `Ctrl-G`.

## `fzf-tab` Completion Contexts

| Context | Preview |
|---|---|
| `cd`, `z` | Directory contents (`eza -1 --color=always --icons=always`, else `ls -1G` on macOS / `ls -1 --color=always` on Linux) |
| `env`, `export` | Current variable value (`${(P)word}`) |
| `unset` | Function definition (`whence -f`) if it is a function, else current variable value |
| `unalias` | Alias definition (`alias "$word"`) |
| `kill`, `killall`, `pkill` | Numeric PID → `ps -p "$word" -o pid,ppid,%cpu,%mem,user,comm --no-headers`; name → `pgrep -af "$word" \| head -20` |
| `ssh` | Resolved config (`ssh -G "$word"` filtering `hostname`/`user`/`port`/`identityfile`/`proxyjump`), else `dig +short "$word" \| head -5` |
| `git-checkout` | `git show --color=always --stat --oneline "$word" \| head -60` |
| `git-diff`, `git-show`, `git-log` | `git show --color=always "$word" \| head -200` |
| `o`, `oooconf` | Subcommand/flag descriptions (`deps`, `secrets`, subcommands) with `--height=45% --layout=reverse --border=top`, `show-group full`, `query-string input` |
| `-command-` | `tldr --color=always "$word"`, falling back to `man "$word"` |
| Everything else (`*`) | Directory (`eza`/`ls`), image (`chafa` when `wezterm` is present), archive (`7z l`), text (`bat` capped at `:500`, else `cat`), or `"System Context: $word"` |

## Shared Content Preview (`zsh-fzf-unified-preview`)

Used by `Ctrl-T` (files/dirs), `Alt-C` (`cd` directories), and `Ctrl-G` (`rg` grep matches). Modeled after `junegunn/fzf`'s `bin/fzf-preview.sh`:

| Target Type | Preview Behavior |
|---|---|
| `FILENAME:LINENO` | Resolves file and centers `bat` / `batcat` with `--highlight-line` on the matching line (used by `Ctrl-G`) |
| Symlink | Prints `symlink -> <target>` (or `Broken symlink: <name> -> <target>`) and previews the resolved target |
| Directory | Shows `git status --short --branch` (up to 40 lines) if inside a git repo, followed by `eza`, `tree -C -L 1`, or `ls` |
| Image (`image/*`) | Uses `kitten icat` (inside Kitty or Ghostty), else `chafa -s "$dim"`, else `imgcat` (iTerm2), sized to `$FZF_PREVIEW_COLUMNS x $FZF_PREVIEW_LINES` |
| Archive (`zip`, `tar`, `bz2`, `gz`, `7z`, `rar`) | Lists contents with `7z l` |
| Text | Highlighted via `bat` or `batcat` (`--style="${BAT_STYLE:-numbers}"`, capped at 500 lines), else `cat` |
| Binary (`*binary*` MIME) | Shows `file` summary plus a hex dump (`xxd -l 256`, else `od -A x -t x1z \| head -24`) |
