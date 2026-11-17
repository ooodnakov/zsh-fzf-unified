# =====================================================================
# zsh-fzf-unified — a single managed source of truth for fzf in zsh.
#
# Consolidates, in one plugin:
#   * fzf shell integration (Ctrl-T / Alt-C) via the fzf --zsh shim
#   * fzf history search (Ctrl-R) — ported from zsh-fzf-history-search
#   * fzf-tab (vendored, pinned to Aloxaf/fzf-tab@24105b1) and ALL of its
#     styling, previously scattered across .zshrc.d/20-completion.zsh
#   * the hybrid Up/Down arrow behaviour
#   * central FZF_* options
#
# Loaded as an Oh My Zsh custom plugin from custom/plugins/zsh-fzf-unified.
# =====================================================================

# Nothing to do without the fzf binary.
(( $+commands[fzf] )) || return 0

# Re-sourcing (second keymap, manual `source`) must be a no-op.
if (( ${+functions[zfz_loaded]} )); then
  return 0
fi
zfz_loaded=1

# Plugin root. $0 is only the plugin file at load time; inside widgets/functions
# it becomes the function name, so capture the directory here and reuse it.
typeset -g zfz_home="${0:A:h}"

# ---------------------------------------------------------------------
# 1. fzf shell integration (Ctrl-T / Alt-C).
#
# `fzf --zsh` (fzf >= 0.48) is the modern shim: it emits the key bindings
# and completion without us having to locate the shell files. It also binds
# its own Tab completion, but fzf-tab (loaded below) rebinds ^I afterwards,
# so Tab stays with fzf-tab. Ctrl-R is rebound below so the history-search
# widget wins.
# ---------------------------------------------------------------------
eval "$(fzf --zsh 2>/dev/null)" || true

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

# Ctrl-R column colors: SGR parameter strings for ESC[...m ('33' yellow,
# '90' bright black, '1;36' bold cyan, '38;5;208' orange). Preset any of
# these BEFORE loading the plugin (e.g. from a theme) to override the
# defaults; set one to '' to leave that field uncolored.
: ${ZFZ_HISTORY_COLOR_EVENT:=33}
: ${ZFZ_HISTORY_COLOR_DATE:=90}
: ${ZFZ_HISTORY_COLOR_TIME:=36}
: ${ZFZ_HISTORY_COLOR_COMMAND:=}

# Set REPLY to $2, wrapped in the SGR sequence $1 when non-empty. Kept
# space-free by contract: rows are split on spaces downstream, so a colored
# field must never introduce one.
zfz_color() {
  if [[ -n "$1" ]]; then
    REPLY=$'\e['"${1}m$2"$'\e[0m'
  else
    REPLY="$2"
  fi
}

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

  # Ctrl-Y copies the command (everything after the "event date time "
  # prefix) to the clipboard and closes the picker without inserting it.
  # fzf --ansi strips the escape codes from '{}' and from the selected
  # line, so the space-separated field layout stays intact downstream.
  local zfz_copy_cmd
  if [[ "$OSTYPE" == darwin* ]]; then
    zfz_copy_cmd='pbcopy'
  elif (( $+commands[xclip] )); then
    zfz_copy_cmd='xclip -selection clipboard'
  elif (( $+commands[wl-copy] )); then
    zfz_copy_cmd='wl-copy'
  else
    zfz_copy_cmd='cat >/dev/null'
  fi

  # Inside the substitution: keep NO comment lines. In an interactive shell
  # without interactive_comments (e.g. zsh -f -i), the runtime re-parse of
  # this text treats '#' as an extendedglob word and dies with
  # "bad pattern: #". The pipeline: fc -li gives ordering, event numbers and
  # the ISO8601 timestamp, but its command text is unsafe for multiline
  # entries; the complete command comes from $history instead. The loop
  # strips a SHARE_HISTORY "*" suffix from foreign event numbers and skips
  # fc continuation lines (non-numeric / non-date / non-time fields).
  # Deduplication: each unique command appears once, newest occurrence kept
  # (fc -li iterates newest-first). Row layout: the event number is the
  # first (prefix) field, never repeated inside the display; fields are
  # joined with a single space (not TAB — a terminal would expand the TAB
  # into a wide gap before the date).
  selected="$(
    {
      fc -li -1 0 |
      while IFS=' ' read -r raw_event date time rest; do
        event="${raw_event%\*}"
        [[ "$event" == <-> ]] || continue
        [[ "$date" == <->-<->-<-> ]] || continue
        [[ "$time" == <->:<-> ]] || continue

        (( ${+history[$event]} )) || continue
        command="${history[$event]}"
        if [[ -n "$ZSH_FZF_HISTORY_SEARCH_REMOVE_DUPLICATES" ]]; then
          (( ${+seen[$command]} )) && continue
          seen[$command]=1
        fi
        display=''
        if (( ZSH_FZF_HISTORY_SEARCH_DATES_IN_SEARCH )); then
          zfz_color "$ZFZ_HISTORY_COLOR_DATE" "$date"
          display+="$REPLY "
          zfz_color "$ZFZ_HISTORY_COLOR_TIME" "$time"
          display+="$REPLY "
        fi
        zfz_color "$ZFZ_HISTORY_COLOR_COMMAND" "$command"
        display+="$REPLY"
        zfz_color "$ZFZ_HISTORY_COLOR_EVENT" "$event"
        printf '%s\0' "$REPLY ${display}"
      done
    } |
      fzf \
        ${=ZSH_FZF_HISTORY_SEARCH_FZF_ARGS} \
        ${=ZSH_FZF_HISTORY_SEARCH_FZF_EXTRA_ARGS} \
        --read0 \
        --ansi \
        --bind "ctrl-y:execute-silent(printf %s '{}' | cut -d' ' -f4- | $zfz_copy_cmd)+abort" \
        "${query_args[@]}"
  )"

  local ret=$?

  if [[ -n "$selected" ]]; then
    # fzf returns "event-number date time command"; the event is the first
    # space-delimited field. Let ZLE restore the original history event so
    # multiline commands come back exactly.
    selected_event="${selected%% *}"
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
# fzf --zsh binds its own Ctrl-R (in emacs/viins/vicmd); rebind all three
# so OUR history search always wins.
for zfz_kmap in emacs viins vicmd; do
  bindkey -M "$zfz_kmap" '^R' fzf_history_search
done
unset zfz_kmap

# ---------------------------------------------------------------------
# 3. Hybrid Up/Down arrows.
#
#   * Multiline buffer: Up/Down move the cursor between lines;
#     history is only touched at the buffer boundary lines.
#   * Single-line buffer: Up opens the fzf history picker, Down walks
#     the history.
# ---------------------------------------------------------------------
zfz_up() {
  if [[ $BUFFER == *$'\n'* ]]; then
    zle up-line-or-history
  else
    zle fzf_history_search
  fi
}
zle -N zfz_up

for zfz_keymap in emacs viins vicmd; do
  bindkey -M "$zfz_keymap" '^[[A' zfz_up
  bindkey -M "$zfz_keymap" '^[OA' zfz_up
  bindkey -M "$zfz_keymap" '^[[B' down-line-or-history
  bindkey -M "$zfz_keymap" '^[OB' down-line-or-history
  if [[ -n "${terminfo[kcuu1]}" ]]; then
    bindkey -M "$zfz_keymap" "${terminfo[kcuu1]}" zfz_up
  fi
  if [[ -n "${terminfo[kcud1]}" ]]; then
    bindkey -M "$zfz_keymap" "${terminfo[kcud1]}" down-line-or-history
  fi
done
unset zfz_keymap

# ---------------------------------------------------------------------
# 4. fzf-tab (vendored) — fzf-based Tab completion, plus its full styling
#    (previously maintained in .zshrc.d/20-completion.zsh).
# ---------------------------------------------------------------------
source "$zfz_home/vendor/fzf-tab/fzf-tab.plugin.zsh"

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

# Variable values for env/export; function definitions for unset; alias
# definitions for unalias (cf. fzf's _fzf_comprun recipes).
zstyle ':fzf-tab:complete:(env|export):*' fzf-preview 'print -r -- "${(P)word}"'
zstyle ':fzf-tab:complete:unset:*' fzf-preview '
  if (( ${+functions[$word]} )); then
    whence -f "$word"
  else
    print -r -- "${(P)word}"
  fi'
zstyle ':fzf-tab:complete:unalias:*' fzf-preview 'alias "$word"'

# Process preview for kill/killall/pkill (numeric PID -> ps, name -> pgrep).
zstyle ':fzf-tab:complete:(kill|killall|pkill):*' fzf-preview '
  if [[ $word =~ ^[0-9]+$ ]]; then
    ps -p "$word" -o pid,ppid,%cpu,%mem,user,comm --no-headers 2>/dev/null
  else
    pgrep -af "$word" 2>/dev/null | head -20
  fi'

# SSH host preview: resolved config, else DNS.
zstyle ':fzf-tab:complete:ssh:*' fzf-preview 'ssh -G "$word" 2>/dev/null | grep -Ei "^(hostname|user|port|identityfile|proxyjump)" || dig +short "$word" 2>/dev/null | head -5'

# Git ref preview for checkout/diff/show/log.
zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview 'git show --color=always --stat --oneline "$word" 2>/dev/null | head -60'
zstyle ':fzf-tab:complete:git-(diff|show|log):*' fzf-preview 'git show --color=always "$word" 2>/dev/null | head -200'

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
      application/zip|application/x-tar|application/x-bzip2|application/x-gzip|application/gzip|application/x-7z-compressed|application/x-rar)
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

# Yazi-like content preview for the Ctrl-T file widget, via the bundled
# zsh-fzf-unified-preview (dirs/git, images, archives, text, binaries).
# Previews on the right, toggled with Ctrl-/; skip noisy dirs.
export FZF_CTRL_T_OPTS="--preview '$zfz_home/zsh-fzf-unified-preview {}' \
  --preview-window 'right,60%,border-left' \
  --walker-skip '.git,node_modules,target,dist,build' \
  --bind 'ctrl-/:change-preview-window(right,60%,border-left|down,60%,border-top|hidden|)'"

# Alt-C (cd) directory preview: git status + contents, previewed below.
export FZF_ALT_C_OPTS="--preview '$zfz_home/zsh-fzf-unified-preview {}' \
  --preview-window 'down,60%,border-top' \
  --walker-skip '.git,node_modules,target,dist,build' \
  --bind 'ctrl-/:change-preview-window(down,60%,border-top|hidden|)'"

# Consistent look across every fzf instance (Ctrl-T, Ctrl-R, Alt-C, fzf-tab,
# and ad-hoc fzf). Only visual flags — layout/height are left to each widget.
export FZF_DEFAULT_OPTS="--info inline --border --pointer '▍' --marker '▍'"

# Fast, gitignore-respecting file source for file widgets (Ctrl-T).
if (( $+commands[fd] )); then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
elif (( $+commands[rg] )); then
  export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git/*"'
fi

# ---------------------------------------------------------------------
# 6. Ripgrep live search (Ctrl-G).
#
# Search file contents with rg, live-reloading on every keystroke, and
# preview the matched file centred on the matching line (reusing the shared
# preview script's FILE:LINENO support). Enter puts "$EDITOR FILE +LINE" on
# the command line.
# ---------------------------------------------------------------------
zfz_rg() {
  local RG_PREFIX INITIAL_QUERY rg_preview sel ret file line
  RG_PREFIX="${FZF_RG_COMMAND:-rg --column --line-number --no-heading --color=always --smart-case --hidden --glob '!.git/*'}"
  INITIAL_QUERY="${LBUFFER//$'\n'/ }"
  rg_preview="$zfz_home/zsh-fzf-unified-preview"

  sel="$(
    fzf --ansi --disabled --query "$INITIAL_QUERY" \
      --bind "start:reload:$RG_PREFIX {q} || true" \
      --bind "change:reload:sleep 0.1; $RG_PREFIX {q} || true" \
      --delimiter : \
      --preview "$rg_preview {1}:{2}" \
      --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
      --layout reverse \
      --prompt 'rg> ' \
      --header 'ENTER: open in $EDITOR at line'
  )"
  ret=$?

  if [[ -n "$sel" ]]; then
    file="${sel%%:*}"
    line="${${sel#*:}%%:*}"
    BUFFER="${EDITOR:-vim} $file +${line:-1}"
    CURSOR=${#BUFFER}
  fi
  zle reset-prompt
  return $ret
}
zle -N zfz_rg
for zfz_kmap in emacs viins vicmd; do
  bindkey -M "$zfz_kmap" '^G' zfz_rg
done
unset zfz_kmap