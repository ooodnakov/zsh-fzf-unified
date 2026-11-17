# =====================================================================
# ooodnakov-fzf — single managed source of truth for fzf in zsh.
#
# Consolidates, in one plugin:
#   * fzf shell integration (Ctrl-T / Alt-C) from the installed fzf
#   * fzf history search (Ctrl-R) — ported from zsh-fzf-history-search
#   * fzf-tab (vendored, pinned to Aloxaf/fzf-tab@24105b1) and ALL of its
#     styling, previously scattered across .zshrc.d/20-completion.zsh
#   * the hybrid Up/Down arrow behaviour
#   * central FZF_* options
#
# Loaded as an Oh My Zsh custom plugin from custom/plugins/ooodnakov-fzf.
# =====================================================================

# Nothing to do without the fzf binary.
(( $+commands[fzf] )) || return 0

# Re-sourcing (second keymap, manual `source`) must be a no-op.
if (( ${+functions[ooodnakov_fzf_loaded]} )); then
  return 0
fi
ooodnakov_fzf_loaded=1

# ---------------------------------------------------------------------
# 1. fzf shell integration (Ctrl-T / Alt-C).
#
# Best-effort: locate the key-bindings.zsh shipped by the installed fzf
# and source it. completion.zsh is deliberately NOT sourced — fzf-tab
# already owns Tab completion. fzf's own Ctrl-R is rebound below so the
# history-search widget wins.
# ---------------------------------------------------------------------
{
  local ooodnakov_fzf_shell="${FZF_SHELL_DIR:-}"
  local ooodnakov_fzf_bin ooodnakov_fzf_prefix ooodnakov_fzf_cand

  # Homebrew / Linuxbrew layout: <prefix>/bin/fzf, shell files at
  # <prefix>/opt/fzf/shell. Derive the prefix from the fzf binary so we
  # never pay for a `brew --prefix` subprocess on every shell start.
  if [[ -z "$ooodnakov_fzf_shell" && -n "${commands[fzf]}" ]]; then
    # NOTE: no :A here — resolving the Homebrew symlink into Cellar would
    # take us past the opt link that actually holds the shell files.
    ooodnakov_fzf_bin="${commands[fzf]}"
    ooodnakov_fzf_prefix="${ooodnakov_fzf_bin:h:h}"
    if [[ -r "$ooodnakov_fzf_prefix/opt/fzf/shell/key-bindings.zsh" ]]; then
      ooodnakov_fzf_shell="$ooodnakov_fzf_prefix/opt/fzf/shell"
    fi
  fi

  # Distro package layouts (Debian/Ubuntu/Arch/macports).
  if [[ -z "$ooodnakov_fzf_shell" ]]; then
    for ooodnakov_fzf_cand in \
      /usr/share/fzf \
      /usr/share/doc/fzf/examples \
      /usr/local/share/fzf; do
      if [[ -r "$ooodnakov_fzf_cand/key-bindings.zsh" ]]; then
        ooodnakov_fzf_shell="$ooodnakov_fzf_cand"
        break
      fi
    done
    unset ooodnakov_fzf_cand
  fi

  if [[ -n "$ooodnakov_fzf_shell" ]]; then
    source "$ooodnakov_fzf_shell/key-bindings.zsh"
  fi
  unset ooodnakov_fzf_shell ooodnakov_fzf_bin ooodnakov_fzf_prefix
}

# ---------------------------------------------------------------------
# 2. fzf history search (Ctrl-R).
#
# Ported from zsh-fzf-history-search. Multiline-safe: entries are framed
# with NUL so embedded newlines belong to the command, not to fzf rows.
# ---------------------------------------------------------------------
typeset -g ZSH_FZF_HISTORY_SEARCH_BIND='^r'
typeset -g ZSH_FZF_HISTORY_SEARCH_FZF_ARGS='+s +m -x -e'
typeset -g ZSH_FZF_HISTORY_SEARCH_FZF_EXTRA_ARGS='--height=~5'
typeset -g ZSH_FZF_HISTORY_SEARCH_END_OF_LINE=''
typeset -g ZSH_FZF_HISTORY_SEARCH_EVENT_NUMBERS=1
typeset -g ZSH_FZF_HISTORY_SEARCH_DATES_IN_SEARCH=1
typeset -g ZSH_FZF_HISTORY_SEARCH_REMOVE_DUPLICATES=1
typeset -g ZSH_FZF_HISTORY_SEARCH_FZF_QUERY_PREFIX=''

fzf_history_search() {
  setopt extendedglob

  # $history maps event numbers to the complete history entry,
  # including embedded newlines.
  zmodload -F zsh/parameter p:history 2>/dev/null || return 1

  local selected selected_event
  local raw_event event date time rest command display
  local -A seen
  local -a query_args

  if (( $#BUFFER )); then
    query_args=(
      -q "${ZSH_FZF_HISTORY_SEARCH_FZF_QUERY_PREFIX}${BUFFER}"
    )
  fi

  selected="$(
    {
      # fc -li gives ordering, event numbers and the ISO8601 timestamp,
      # but its command text is unsafe for multiline entries; the complete
      # command comes from $history instead.
      fc -li -1 0 |
      while IFS=' ' read -r raw_event date time rest; do
        # SHARE_HISTORY can display foreign events as "123*".
        event="${raw_event%\*}"

        # Ignore continuation lines from fc output.
        [[ "$event" == <-> ]] || continue
        [[ "$date" == <->-<->-<-> ]] || continue
        [[ "$time" == <->:<-> ]] || continue

        (( ${+history[$event]} )) || continue
        command="${history[$event]}"

        display=''
        if (( ZSH_FZF_HISTORY_SEARCH_EVENT_NUMBERS )); then
          display+="${event} "
        fi
        if (( ZSH_FZF_HISTORY_SEARCH_DATES_IN_SEARCH )); then
          display+="${date} ${time} "
        fi
        display+="${command}"

        # Deduplicate exactly what would be displayed/searched.
        if [[ -n "$ZSH_FZF_HISTORY_SEARCH_REMOVE_DUPLICATES" ]]; then
          (( ${+seen[$display]} )) && continue
          seen[$display]=1
        fi

        # event-number<TAB>display text<NUL>
        printf '%s\0' "${event}"$'\t'"${display}"
      done
    } |
      fzf \
        ${=ZSH_FZF_HISTORY_SEARCH_FZF_ARGS} \
        ${=ZSH_FZF_HISTORY_SEARCH_FZF_EXTRA_ARGS} \
        --read0 \
        "${query_args[@]}"
  )"

  local ret=$?

  if [[ -n "$selected" ]]; then
    # fzf returns event-number<TAB>...; let ZLE restore the original
    # history event so multiline commands come back exactly.
    selected_event="${selected%%$'\t'*}"
    if [[ "$selected_event" == <-> ]]; then
      zle vi-fetch-history -n "$selected_event"
      if [[ -n "$ZSH_FZF_HISTORY_SEARCH_END_OF_LINE" ]]; then
        zle end-of-line
      fi
    fi
  fi

  zle reset-prompt
  return $ret
}

zle -N fzf_history_search
# fzf's key-bindings.zsh binds its own Ctrl-R (in emacs/viins/vicmd);
# rebind all three so OUR history search always wins.
for ooodnakov_kmap in emacs viins vicmd; do
  bindkey -M "$ooodnakov_kmap" '^R' fzf_history_search
done
unset ooodnakov_kmap

# ---------------------------------------------------------------------
# 3. Hybrid Up/Down arrows.
#
#   * Multiline buffer: Up/Down move the cursor between lines;
#     history is only touched at the buffer boundary lines.
#   * Single-line buffer: Up opens the fzf history picker, Down walks
#     the history.
# ---------------------------------------------------------------------
ooodnakov_up() {
  if [[ $BUFFER == *$'\n'* ]]; then
    zle up-line-or-history
  else
    zle fzf_history_search
  fi
}
zle -N ooodnakov_up

for ooodnakov_keymap in emacs viins vicmd; do
  bindkey -M "$ooodnakov_keymap" '^[[A' ooodnakov_up
  bindkey -M "$ooodnakov_keymap" '^[OA' ooodnakov_up
  bindkey -M "$ooodnakov_keymap" '^[[B' down-line-or-history
  bindkey -M "$ooodnakov_keymap" '^[OB' down-line-or-history
  if [[ -n "${terminfo[kcuu1]}" ]]; then
    bindkey -M "$ooodnakov_keymap" "${terminfo[kcuu1]}" ooodnakov_up
  fi
  if [[ -n "${terminfo[kcud1]}" ]]; then
    bindkey -M "$ooodnakov_keymap" "${terminfo[kcud1]}" down-line-or-history
  fi
done
unset ooodnakov_keymap

# ---------------------------------------------------------------------
# 4. fzf-tab (vendored) — fzf-based Tab completion, plus its full styling
#    (previously maintained in .zshrc.d/20-completion.zsh).
# ---------------------------------------------------------------------
source "${0:A:h}/vendor/fzf-tab/fzf-tab.plugin.zsh"

zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:*' fzf-bindings-default tab:down,btab:up,change:top,alt-s:toggle,bspace:backward-delete-char/eof,ctrl-h:backward-delete-char/eof

# Directory previews (cd / z): eza when available, else coloured ls.
if (( $+commands[eza] )); then
  zstyle ':fzf-tab:complete:(cd|z):*' fzf-preview 'eza -1 --color=always --icons=always $realpath'
elif [[ "$OSTYPE" == "darwin"* ]]; then
  zstyle ':fzf-tab:complete:(cd|z):*' fzf-preview 'ls -1G $realpath'
else
  zstyle ':fzf-tab:complete:(cd|z):*' fzf-preview 'ls -1 --color=always $realpath'
fi

# oooconf previews.
zstyle ':fzf-tab:complete:(o|oooconf):*' fzf-flags --height=45% --layout=reverse --border=top
zstyle ':fzf-tab:complete:(o|oooconf):*' show-group full
zstyle ':fzf-tab:complete:(o|oooconf):*' query-string input
zstyle ':fzf-tab:complete:(o|oooconf):*' fzf-preview '
  subcmd="${words[2]}"

  case "$subcmd" in
    deps)
      printf "dependency: %s\n\n%s\n" "$word" "$desc"
      ;;
    secrets)
      # Streamlined lookahead check for the 3rd argument
      if [[ -n "${words[3]}" && "${words[3]}" != "$word" ]]; then
        printf "secrets %s\n\n%s\n" "$word" "$desc"
      else
        printf "subcommand: %s\n\n%s\n" "$word" "$desc"
      fi
      ;;
    ""|-*)
      printf "command: %s\n\n%s\n" "$word" "$desc"
      ;;
    *)
      printf "%s\n\n%s\n" "$word" "$desc"
      ;;
  esac
'

# Command previews: tldr when available, else man.
if (( $+commands[tldr] )); then
  zstyle ':fzf-tab:complete:-command-:*' fzf-preview 'tldr --color=always "$word" 2>/dev/null || man "$word" 2>/dev/null'
else
  zstyle ':fzf-tab:complete:-command-:*' fzf-preview 'man "$word" 2>/dev/null'
fi

# Generic fallback preview for all files and folders.
zstyle ':fzf-tab:complete:*' fzf-preview '
  # DIRECTORY PREVIEWS
  if [[ -d "$realpath" ]]; then
    eza -1 --color=always --icons=always "$realpath" 2>/dev/null || ls -1G "$realpath"

  # FILE PREVIEWS
  elif [[ -f "$realpath" ]]; then
    mime=$(file --mime-type -b "$realpath")

    case "$mime" in
      # IMAGE PREVIEWS (WezTerm Native)
      image/*)
        if (( $+commands[wezterm] )); then
          chafa "$realpath"
        else
          printf "Image: %s\n(wezterm binary not found in PATH)" "$(basename "$realpath")"
        fi
        ;;

      # ARCHIVE PREVIEWS (7-Zip Only)
      application/zip|application/x-tar|application/x-bzip2|application/x-gzip|application/x-7z-compressed|application/x-rar)
        if (( $+commands[7z] )); then
          7z l "$realpath" 2>/dev/null
        else
          printf "Archive: %s\n(Install 7z to preview contents)" "$(basename "$realpath")"
        fi
        ;;

      # TEXT/CODE PREVIEWS
      *)
        if (( $+commands[bat] )); then
          bat --style=numbers --color=always --line-range :500 "$realpath" 2>/dev/null
        else
          cat "$realpath" 2>/dev/null
        fi
        ;;
    esac
  else
    printf "System Context: %s\n" "$word"
  fi
'

# Safe safeguard for the fzf history picker: Enter accepts, no run.
export FZF_CTRL_R_OPTS="--bind 'enter:accept'"