# zsh-fzf-unified

A single managed source of truth for fzf inside zsh. One plugin that owns:

- **fzf shell integration** — Ctrl-T (paste file/dir) and Alt-C (cd) via the
  modern `fzf --zsh` shim (fzf ≥ 0.48). No manual location of the shell files.
- **fzf history search** — Ctrl-R and the Up-arrow hybrid. Ported from
  `zsh-fzf-history-search`: multiline-safe via NUL-framed entries; event
  numbers and ISO8601 dates shown; duplicates removed.
- **fzf-tab** — vendored, pinned to `Aloxaf/fzf-tab@24105b1`, including all of
  its styling (directory/command/file previews, oooconf completions) that used
  to live in `.zshrc.d/20-completion.zsh`.
- **Hybrid Up/Down arrows** — on a multiline buffer the arrows move the cursor
  between lines (history only at the boundary lines); on a single-line buffer
  Up opens the fzf history picker and Down walks history.
- **Central `FZF_*` options** — e.g. `FZF_CTRL_R_OPTS=--bind 'enter:accept'`,
  a Yazi-like content preview for Ctrl-T, and a directory preview for Alt-C.
  The shared preview script handles dirs (git status + eza/tree/ls), symlinks,
  images (kitten icat / chafa / imgcat), archives (7z), text (bat) and binaries
  (xxd/od) — modeled after `junegunn/fzf`'s `bin/fzf-preview.sh`.
- **fzf-tab completion previews** — in addition to file/dir/command previews,
  `env`/`export` show the variable value, `unset` shows the function definition
  or value, and `unalias` shows the alias definition.

## Install (Oh My Zsh)

Put the plugin under `$ZSH_CUSTOM/plugins/zsh-fzf-unified` and add it to
`plugins=( ... zsh-fzf-unified )` in `.zshrc`. Requires `fzf` on `PATH`; without
it the plugin is a no-op.

## Layout

```
zsh-fzf-unified.plugin.zsh   # OMZ entry point (resolves plugin root)
zsh-fzf-unified.zsh          # all fzf logic (integration + history + arrows + fzf-tab)
zsh-fzf-unified-preview      # Yazi-like content preview for Ctrl-T
vendor/fzf-tab/              # Aloxaf/fzf-tab pinned to 24105b1
```

## Updating vendored fzf-tab

```sh
curl -sL https://github.com/Aloxaf/fzf-tab/archive/<sha>.tar.gz | \
  tar xz --strip-components=1 -C vendor/fzf-tab --exclude='.git'
```

## Notes

- `fzf --zsh` binds its own Tab completion and Ctrl-R; fzf-tab (loaded last)
  rebinds Tab, and this plugin rebinds Ctrl-R in all keymaps, so those two
  widgets always win.
- The plugin is a no-op when the `fzf` binary is missing, mirroring upstream
  `zsh-fzf-history-search`.