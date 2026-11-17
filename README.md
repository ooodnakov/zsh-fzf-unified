# ooodnakov-fzf

Single managed source of truth for fzf inside zsh. One plugin that owns:

- **fzf shell integration** — Ctrl-T (paste file/dir) and Alt-C (cd) from the
  installed fzf's `key-bindings.zsh`. Located best-effort (Homebrew/Linuxbrew
  prefix derived from the fzf binary, then distro paths). fzf's `completion.zsh`
  is deliberately **not** sourced because fzf-tab owns Tab completion.
- **fzf history search** — Ctrl-R and the Up-arrow hybrid. Ported from
  `zsh-fzf-history-search`: multiline-safe via NUL-framed entries; event
  numbers and ISO8601 dates shown; duplicates removed.
- **fzf-tab** — vendored, pinned to `Aloxaf/fzf-tab@24105b1`, including all of
  its styling (directory/command/file previews, oooconf completions) that used
  to live in `.zshrc.d/20-completion.zsh`.
- **Hybrid Up/Down arrows** — on a multiline buffer the arrows move the cursor
  between lines (history only at the boundary lines); on a single-line buffer
  Up opens the fzf history picker and Down walks history.
- **Central `FZF_*` options** — e.g. `FZF_CTRL_R_OPTS=--bind 'enter:accept'`.

## Install (Oh My Zsh)

Put the plugin under `$ZSH_CUSTOM/plugins/ooodnakov-fzf` and add it to
`plugins=( ... ooodnakov-fzf )` in `.zshrc`. Requires `fzf` on `PATH`; without
it the plugin is a no-op.

## Layout

```
ooodnakov-fzf.plugin.zsh   # OMZ entry point (resolves plugin root)
ooodnakov-fzf.zsh          # all fzf logic (integration + history + arrows + fzf-tab)
vendor/fzf-tab/            # Aloxaf/fzf-tab pinned to 24105b1
```

## Updating vendored fzf-tab

```sh
curl -sL https://github.com/Aloxaf/fzf-tab/archive/<sha>.tar.gz | \
  tar xz --strip-components=1 -C vendor/fzf-tab --exclude='.git'
```

## Notes

- fzf's own Ctrl-R is rebound after `key-bindings.zsh` is sourced so this
  plugin's history search always wins.
- The plugin is a no-op when the `fzf` binary is missing, mirroring upstream
  `zsh-fzf-history-search`.