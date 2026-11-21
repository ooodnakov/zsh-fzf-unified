# Why Unified

In typical zsh setups, fzf integrations accumulate across three or four separate plugins and config snippets:

- `zsh-fzf-history-search` for `Ctrl-R`
- `eval "$(fzf --zsh)"` for `Ctrl-T`, `Alt-C`, and its own `Ctrl-R` / `Tab`
- `fzf-tab` for `Tab` completion
- Scattered `zstyle` rules and ad-hoc preview snippets

Because they bind overlapping keys (`Tab`, `Ctrl-R`, `Up`/`Down`), whichever plugin loads last wins silently. Changing plugin order or adding a keymap breaks bindings without warning.

## What `zsh-fzf-unified` Solves

- **Single source of truth with explicit precedence:** `fzf --zsh` binds `Tab` and `Ctrl-R` first; vendored `fzf-tab` rebinds `Tab`; `zsh-fzf-unified` rebinds `Ctrl-R` and `Ctrl-G` across `emacs`, `viins`, and `vicmd` and installs hybrid `Up`/`Down` arrow widgets. See [Architecture & Precedence](/reference/architecture).
- **Multiline history as a first-class case:** History entries are framed with `NUL` (`--read0`) so embedded newlines never leak into picker rows, and `Up`/`Down` move the cursor between lines inside multiline buffers instead of jumping straight into history. See [Ctrl-R History Search](/guide/history-search).
- **Consistent visuals and universal previews:** Every fzf surface shares `FZF_DEFAULT_OPTS` and gets contextual or content previews — directories, git status, symlinks, images, archives, highlighted code, hex dumps, git commits, SSH config, env vars, processes, and grep matches. See [Previews & fzf-tab Contexts](/guide/previews).
- **Idempotent loading:** Sourcing the plugin more than once (e.g. second keymap or manual `source`) is a safe no-op (`zfz_loaded`), and without `fzf` on `PATH` it exits cleanly as a no-op.
