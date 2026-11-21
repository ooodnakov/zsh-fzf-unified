# Global fzf Options

`zsh-fzf-unified` exports consistent global options for `fzf --zsh`, `fzf-tab`, `Ctrl-G`, and ad-hoc `fzf` invocations.

## Exported & Used Variables

| Variable | Value / Default | Purpose |
|---|---|---|
| `FZF_DEFAULT_OPTS` | `--info inline --border --pointer '▍' --marker '▍'` | Consistent visual chrome across all fzf surfaces (layout/height are left to each widget) |
| `FZF_DEFAULT_COMMAND` | `fd --type f --hidden --follow --exclude .git` (fallback: `rg --files --hidden --glob "!.git/*"`) | Fast, gitignore-respecting file listing for `Ctrl-T` when `fd` or `rg` is available |
| `FZF_CTRL_T_OPTS` | Right preview (`60%`, `border-left`), skips `.git,node_modules,target,dist,build`, `Ctrl-/` cycles `right` → `down` → `hidden` | File/directory widget options |
| `FZF_ALT_C_OPTS` | Bottom preview (`60%`, `border-top`), skips `.git,node_modules,target,dist,build`, `Ctrl-/` cycles `down` → `hidden` | Directory `cd` widget options |
| `FZF_CTRL_R_OPTS` | `--bind 'enter:accept'` | Safety default ensuring `Enter` accepts rather than executing |
| `FZF_RG_COMMAND` | `rg --column --line-number --no-heading --color=always --smart-case --hidden --glob '!.git/*'` | Ripgrep command reloaded on keystrokes by `Ctrl-G` (`zfz_rg`) — reads user override if already set |

## Exact Definitions

```zsh
export FZF_CTRL_R_OPTS="--bind 'enter:accept'"

export FZF_CTRL_T_OPTS="--preview '$zfz_home/zsh-fzf-unified-preview {}' \
  --preview-window 'right,60%,border-left' \
  --walker-skip '.git,node_modules,target,dist,build' \
  --bind 'ctrl-/:change-preview-window(right,60%,border-left|down,60%,border-top|hidden|)'"

export FZF_ALT_C_OPTS="--preview '$zfz_home/zsh-fzf-unified-preview {}' \
  --preview-window 'down,60%,border-top' \
  --walker-skip '.git,node_modules,target,dist,build' \
  --bind 'ctrl-/:change-preview-window(down,60%,border-top|hidden|)'"

export FZF_DEFAULT_OPTS="--info inline --border --pointer '▍' --marker '▍'"
```

## Customizing Ripgrep Search (`Ctrl-G`)

Because `zfz_rg` reads `${FZF_RG_COMMAND:-...}` dynamically, you can customize search flags (for example adding `--follow` or custom globs) in `.zshrc`:

```zsh
export FZF_RG_COMMAND="rg --column --line-number --no-heading --color=always --smart-case --follow"
```
