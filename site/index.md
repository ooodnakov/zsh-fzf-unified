---
layout: home

hero:
  name: zsh-fzf-unified
  text: One plugin for every fzf surface in zsh.
  tagline: Shell integration (Ctrl-T / Alt-C), multiline-safe history search (Ctrl-R), live ripgrep search (Ctrl-G), vendored fzf-tab completion, and hybrid Up/Down arrows — with defined precedence.
  image:
    src: /logo.svg
    alt: zsh-fzf-unified
  actions:
    - theme: brand
      text: Get Started
      link: /guide/why
    - theme: alt
      text: Keybindings
      link: /guide/keybindings
    - theme: alt
      text: GitHub
      link: https://github.com/ooodnakov/zsh-fzf-unified

features:
  - title: Deterministic Precedence
    details: Owns fzf --zsh, vendored fzf-tab, Ctrl-R, Ctrl-G, and Up/Down arrows in one place so plugins never silently overwrite each other.
  - title: Multiline-Safe History
    details: Frames entries with NUL, keeps newest duplicates, formats colored event/date/time columns, and restores exact commands via vi-fetch-history.
  - title: Universal Content Previews
    details: Context-aware fzf-tab previews plus a shared Yazi-like preview script for directories, git repos, symlinks, images, archives, code, binaries, and grep lines.
  - title: Live Ripgrep Search
    details: Ctrl-G reloads rg on every keystroke, centers previews on the matched line, and drops $EDITOR FILE +LINE straight onto the prompt.
---

## Keybindings at a Glance

| Key | Action |
|---|---|
| `Ctrl-R` | Deduplicated, multiline-safe fzf history search (`Ctrl-Y` copies command) |
| `Up` / `Down` | Hybrid arrows: cursor motion in multiline buffers, picker / history on single line |
| `Ctrl-T` | File and directory picker with right preview (60%), toggled with `Ctrl-/` |
| `Alt-C` | `cd` directory picker with bottom preview (60%), toggled with `Ctrl-/` |
| `Ctrl-G` | Live `rg` grep picker (`Enter` puts `$EDITOR FILE +LINE` on the command line) |
| `Tab` | Vendored `fzf-tab` completion with per-context previews |
| `<` / `>` | Switch `fzf-tab` completion groups |

## Quick Install

::: code-group

```sh [Oh My Zsh]
git clone https://github.com/ooodnakov/zsh-fzf-unified \
  "${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-fzf-unified"
```

```zsh [.zshrc (Oh My Zsh)]
# Remove zsh-fzf-history-search, standalone fzf-tab, and `fzf --zsh` lines first
plugins=( ... zsh-fzf-unified )
```

```zsh [Direct source (without OMZ)]
source /path/to/zsh-fzf-unified/zsh-fzf-unified.plugin.zsh
```

:::
