# Architecture & Precedence

## Repository Layout

```txt
zsh-fzf-unified.plugin.zsh   # OMZ entry point (resolves plugin root)
zsh-fzf-unified.zsh          # all fzf logic: integration, Ctrl-R, arrows, Ctrl-G, fzf-tab styling
zsh-fzf-unified-preview      # shared content preview script (dirs/git, images, archives, text, binaries)
vendor/fzf-tab/              # Aloxaf/fzf-tab pinned to 24105b1
LICENSE                      # MIT
THIRD-PARTY.md               # vendored/ported upstream notices
```

## Load Order & Binding Precedence

Precedence is deterministic inside `zsh-fzf-unified.zsh`:

1. **Guard checks:**
   - Exits immediately if `fzf` is missing from `$commands`.
   - Exits as a no-op if `zfz_loaded` is already set (safe against double-sourcing or multiple keymap setups).
   - Captures `zfz_home="${0:A:h}"` at load time so widgets and previews always resolve bundled assets.
2. **Base integration (`eval "$(fzf --zsh)"`):** Installs upstream `Ctrl-T`, `Alt-C`, `Tab`, and `Ctrl-R`.
3. **`Ctrl-R` (`fzf_history_search`):** Rebinds `^R` in `emacs`, `viins`, and `vicmd` so the multiline-safe history search wins over `fzf --zsh`.
4. **Hybrid `Up`/`Down` arrows (`zfz_up` / `down-line-or-history`):** Bound across `emacs`, `viins`, and `vicmd` (plus `${terminfo[kcuu1]}` and `${terminfo[kcud1]}` when present).
5. **Vendored `fzf-tab` (`vendor/fzf-tab/fzf-tab.plugin.zsh`):** Loaded after `fzf --zsh` so `fzf-tab` wins `^I` (`Tab`), followed by all `zstyle ':fzf-tab:*'` rules.
6. **Global `FZF_*` variables:** Sets `FZF_CTRL_R_OPTS`, `FZF_CTRL_T_OPTS`, `FZF_ALT_C_OPTS`, `FZF_DEFAULT_OPTS`, and `FZF_DEFAULT_COMMAND`.
7. **Live ripgrep (`zfz_rg`):** Binds `^G` across `emacs`, `viins`, and `vicmd`.

## Line Endings (`.gitattributes`)

The repository enforces `* text=auto eol=lf` in `.gitattributes`, because zsh/bash treat trailing carriage returns in scripts and ANSI helpers as data rather than whitespace.

## Updating Vendored `fzf-tab`

`Aloxaf/fzf-tab` is vendored in `vendor/fzf-tab/` and pinned to commit `24105b1`:

```sh
curl -sL https://github.com/Aloxaf/fzf-tab/archive/<sha>.tar.gz | \
  tar xz --strip-components=1 -C vendor/fzf-tab --exclude='.git'
```
