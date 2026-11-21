# Install & Requirements

## Requirements

- **`zsh`**
- **[`fzf`](https://github.com/junegunn/fzf) ≥ 0.48** (required for the `fzf --zsh` shell integration shim; without `fzf` in `PATH`, loading the plugin is a no-op).
- **Oh My Zsh** for the `custom/plugins/` layout — or source `zsh-fzf-unified.plugin.zsh` directly in `.zshrc`.

### Optional Auto-Detected Tools

| Capability | Tools Checked |
|---|---|
| File sources (`FZF_DEFAULT_COMMAND`) | `fd`, else `rg` |
| Live grep (`Ctrl-G`) | `rg` |
| Directory previews | `eza`, `tree`, else `ls` |
| Text / code previews | `bat` / `batcat`, else `cat` |
| Image previews | `kitten icat` (Kitty / Ghostty), `chafa`, `imgcat` (iTerm2) |
| Archive previews | `7z` |
| Command help (`-command-` completion) | `tldr`, else `man` |
| Clipboard copy (`Ctrl-Y` in `Ctrl-R`) | `pbcopy` (macOS), `xclip`, `wl-copy` |
| Binary previews | `xxd`, else `od` |

## Install with Oh My Zsh

Clone the repository into your Oh My Zsh custom plugins directory:

```sh
git clone https://github.com/ooodnakov/zsh-fzf-unified \
  "${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-fzf-unified"
```

Enable it in `~/.zshrc`:

```zsh
# .zshrc
plugins=( ... zsh-fzf-unified )
```

::: warning Remove predecessors before enabling
Removing predecessors is part of the deal — drop:
- `zsh-fzf-history-search` from `plugins=()`
- any standalone `fzf-tab` clone or `source` line
- any standalone `fzf` shell-integration lines (`eval "$(fzf --zsh)"`, `source ...key-bindings.zsh`, `source ...completion.zsh`)

`zsh-fzf-unified` replaces all of them.
:::

## Manual / Direct Source

If you do not use Oh My Zsh, clone anywhere and source the plugin entry file (it resolves its own root directory so `vendor/fzf-tab/` and `zsh-fzf-unified-preview` are always found):

```zsh
source /path/to/zsh-fzf-unified/zsh-fzf-unified.plugin.zsh
```

Set any [configuration variables](/config/behavior) **before** loading the plugin (for example in `.zshrc.d/*.zsh` or above `plugins=(...)`).
