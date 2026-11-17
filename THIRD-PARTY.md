# Third-party code

`zsh-fzf-unified` is MIT-licensed (see `LICENSE`). It contains or derives from
the following MIT-licensed work; the original copyright notices apply to those
portions and must be retained on redistribution.

## Vendored

| Project | Copyright | Location | License |
|---------|-----------|----------|---------|
| [Aloxaf/fzf-tab](https://github.com/Aloxaf/fzf-tab) @ `24105b1` | (c) 2019-2026 Aloxaf | `vendor/fzf-tab/` | `vendor/fzf-tab/LICENSE` |
| [zsh-ls-colors](https://github.com/trapd00r/zsh-ls-colors) | (c) 2019 Gamma | `vendor/fzf-tab/lib/zsh-ls-colors/` | `vendor/fzf-tab/lib/zsh-ls-colors/LICENSE` |

## Ported / modeled

| Project | Copyright | Use |
|---------|-----------|-----|
| [joshskidmore/zsh-fzf-history-search](https://github.com/joshskidmore/zsh-fzf-history-search) | (c) 2020 Josh Skidmore | Ctrl-R history widget, ported and extended in `zsh-fzf-unified.zsh` |
| [junegunn/fzf](https://github.com/junegunn/fzf) | (c) 2013-2026 Junegunn Choi | `zsh-fzf-unified-preview` is modeled after `bin/fzf-preview.sh`; the `fzf --zsh` shim is used as-is |

MIT License text for each applies verbatim as reproduced in their repositories.
