<script setup lang="ts">
import { computed, ref } from 'vue'

type ModeId = 'ctrl-r' | 'ctrl-t' | 'ctrl-g' | 'tab'
type TabGroupId = 'local-directory' | 'options'

interface ModeTab {
  id: ModeId
  label: string
  ariaLabel: string
}

interface HistoryItem {
  id: string
  event: number
  date: string
  time: string
  lines: string[]
  raw: string
}

interface FileItem {
  id: string
  name: string
  kind: 'file' | 'dir'
  meta: string
  previewHeader: string
  previewLines: { num?: string; text: string; highlight?: boolean }[]
}

interface GrepMatch {
  id: string
  file: string
  line: number
  snippet: string
  context: { num: number; text: string; matched?: boolean }[]
}

interface TabCandidate {
  id: string
  label: string
  kind: 'dir' | 'file' | 'flag'
  previewTitle: string
  previewLines: string[]
}

const MODES: readonly ModeTab[] = [
  { id: 'ctrl-r', label: 'Ctrl-R', ariaLabel: 'Ctrl-R history search mode' },
  { id: 'ctrl-t', label: 'Ctrl-T', ariaLabel: 'Ctrl-T file picker mode' },
  { id: 'ctrl-g', label: 'Ctrl-G', ariaLabel: 'Ctrl-G live ripgrep mode' },
  { id: 'tab', label: 'Tab', ariaLabel: 'Tab fzf-tab completion mode' },
]

const HISTORY_ROWS: readonly HistoryItem[] = [
  {
    id: 'h-4821',
    event: 4821,
    date: '2026-11-22',
    time: '14:32',
    lines: ['cd ~/src/zsh-fzf-unified && \\', '  git log --oneline -n 5'],
    raw: 'cd ~/src/zsh-fzf-unified && \\\n  git log --oneline -n 5',
  },
  {
    id: 'h-4817',
    event: 4817,
    date: '2026-11-22',
    time: '14:18',
    lines: ["rg -n 'fzf_history_search' zsh-fzf-unified.zsh"],
    raw: "rg -n 'fzf_history_search' zsh-fzf-unified.zsh",
  },
  {
    id: 'h-4809',
    event: 4809,
    date: '2026-11-22',
    time: '11:05',
    lines: ['source ./zsh-fzf-unified.plugin.zsh'],
    raw: 'source ./zsh-fzf-unified.plugin.zsh',
  },
  {
    id: 'h-4794',
    event: 4794,
    date: '2026-11-21',
    time: '19:44',
    lines: ['./zsh-fzf-unified-preview site/guide/'],
    raw: './zsh-fzf-unified-preview site/guide/',
  },
]

const FILE_ROWS: readonly FileItem[] = [
  {
    id: 'f-plugin',
    name: 'zsh-fzf-unified.zsh',
    kind: 'file',
    meta: '411 lines · zsh',
    previewHeader: 'bat --style=numbers zsh-fzf-unified.zsh',
    previewLines: [
      { num: '74', text: 'fzf_history_search() {', highlight: true },
      { num: '75', text: '  setopt extendedglob' },
      { num: '79', text: '  zmodload -F zsh/parameter p:history || return 1' },
      { num: '182', text: 'zle -N fzf_history_search' },
      { num: '186', text: "  bindkey -M \"$zfz_kmap\" '^R' fzf_history_search" },
    ],
  },
  {
    id: 'f-preview',
    name: 'zsh-fzf-unified-preview',
    kind: 'file',
    meta: '114 lines · bash',
    previewHeader: 'bat --style=numbers zsh-fzf-unified-preview',
    previewLines: [
      { num: '23', text: 'if [[ $file =~ ^(.+):([0-9]+)[:0-9]*$ ]]; then' },
      { num: '24', text: '  file=${BASH_REMATCH[1]}' },
      { num: '25', text: '  center=${BASH_REMATCH[2]}', highlight: true },
      { num: '42', text: 'if git -C "$file" rev-parse --is-inside-work-tree; then' },
      { num: '43', text: '  git -C "$file" status --short --branch | head -40' },
    ],
  },
  {
    id: 'f-guide',
    name: 'site/guide/',
    kind: 'dir',
    meta: 'dir · git clean',
    previewHeader: 'git status --short --branch && eza -1 site/guide/',
    previewLines: [
      { text: '## main...origin/main' },
      { text: 'history-search.md', highlight: true },
      { text: 'install.md' },
      { text: 'keybindings.md' },
      { text: 'previews.md' },
      { text: 'why.md' },
    ],
  },
  {
    id: 'f-vendor',
    name: 'vendor/fzf-tab/',
    kind: 'dir',
    meta: 'dir · 24105b1',
    previewHeader: 'eza -1 vendor/fzf-tab/',
    previewLines: [
      { text: 'fzf-tab.plugin.zsh', highlight: true },
      { text: 'fzf-tab.zsh' },
      { text: 'lib/' },
      { text: 'modules/' },
      { text: 'LICENSE' },
    ],
  },
]

const GREP_ROWS: readonly GrepMatch[] = [
  {
    id: 'g-74',
    file: 'zsh-fzf-unified.zsh',
    line: 74,
    snippet: 'fzf_history_search() {',
    context: [
      { num: 72, text: '}' },
      { num: 73, text: '' },
      { num: 74, text: 'fzf_history_search() {', matched: true },
      { num: 75, text: '  setopt extendedglob' },
      { num: 76, text: '  # $history maps event numbers to complete entries' },
    ],
  },
  {
    id: 'g-182',
    file: 'zsh-fzf-unified.zsh',
    line: 182,
    snippet: 'zle -N fzf_history_search',
    context: [
      { num: 180, text: '}' },
      { num: 181, text: '' },
      { num: 182, text: 'zle -N fzf_history_search', matched: true },
      { num: 183, text: '# Rebind emacs/viins/vicmd so our search wins.' },
      { num: 184, text: 'for zfz_kmap in emacs viins vicmd; do' },
    ],
  },
  {
    id: 'g-186',
    file: 'zsh-fzf-unified.zsh',
    line: 186,
    snippet: "bindkey -M \"$zfz_kmap\" '^R' fzf_history_search",
    context: [
      { num: 184, text: 'for zfz_kmap in emacs viins vicmd; do' },
      { num: 185, text: '  # override upstream fzf --zsh Ctrl-R binding' },
      { num: 186, text: "  bindkey -M \"$zfz_kmap\" '^R' fzf_history_search", matched: true },
      { num: 187, text: 'done' },
      { num: 188, text: 'unset zfz_kmap' },
    ],
  },
  {
    id: 'g-doc-3',
    file: 'site/guide/history-search.md',
    line: 3,
    snippet: '`fzf_history_search` is ported from joshskidmore...',
    context: [
      { num: 1, text: '# Ctrl-R History Search' },
      { num: 2, text: '' },
      { num: 3, text: '`fzf_history_search` is ported and extended for', matched: true },
      { num: 4, text: 'multiline commands, colored columns, and Ctrl-Y copy.' },
    ],
  },
]

const TAB_GROUPS: Record<TabGroupId, readonly TabCandidate[]> = {
  'local-directory': [
    {
      id: 't-site',
      label: 'site/',
      kind: 'dir',
      previewTitle: 'eza -1 --color=always site/',
      previewLines: ['.vitepress/', 'config/', 'guide/', 'reference/', 'index.md'],
    },
    {
      id: 't-vendor',
      label: 'vendor/',
      kind: 'dir',
      previewTitle: 'eza -1 --color=always vendor/',
      previewLines: ['fzf-tab/  (pinned @ 24105b1)', '  fzf-tab.plugin.zsh', '  fzf-tab.zsh', '  lib/'],
    },
    {
      id: 't-zsh',
      label: 'zsh-fzf-unified.zsh',
      kind: 'file',
      previewTitle: 'bat --line-range :5 zsh-fzf-unified.zsh',
      previewLines: [
        '1  # Unified zsh + fzf integration',
        '2  (( $+commands[fzf] )) || return 0',
        '3  (( $+zfz_loaded )) && return 0',
        '4  typeset -g zfz_loaded=1',
      ],
    },
    {
      id: 't-prev',
      label: 'zsh-fzf-unified-preview',
      kind: 'file',
      previewTitle: 'bat --line-range :5 zsh-fzf-unified-preview',
      previewLines: [
        '1  #!/usr/bin/env bash',
        '2  # Yazi-like preview for Ctrl-T / Alt-C / Ctrl-G',
        '3  # Supports dirs, git, images, archives, text, binary',
      ],
    },
  ],
  options: [
    {
      id: 'o-long',
      label: '--long',
      kind: 'flag',
      previewTitle: 'eza option · --long (-l)',
      previewLines: ['Display extended file metadata in columns', 'permissions · links · size · modified'],
    },
    {
      id: 'o-all',
      label: '--all',
      kind: 'flag',
      previewTitle: 'eza option · --all (-a)',
      previewLines: ['Show hidden files and dotfiles', 'Includes .gitignore and .gitattributes'],
    },
    {
      id: 'o-tree',
      label: '--tree',
      kind: 'flag',
      previewTitle: 'eza option · --tree (-T)',
      previewLines: ['Recurse into directories as a tree', 'Combine with --level=2 to bound depth'],
    },
    {
      id: 'o-git',
      label: '--git',
      kind: 'flag',
      previewTitle: 'eza option · --git',
      previewLines: ['List each file status inside Git working trees', 'Staged and unstaged markers per row'],
    },
  ],
}

const activeMode = ref<ModeId>('ctrl-r')
const selectedHistoryIndex = ref(0)
const historyActionHint = ref<'default' | 'copied' | 'fetched'>('default')

const selectedFileIndex = ref(0)
const ctrlTPreviewVisible = ref(true)

const selectedGrepIndex = ref(0)

const activeTabGroup = ref<TabGroupId>('local-directory')
const selectedTabIndex = ref(0)
const toggledTabIds = ref<string[]>([])

const activeHistory = computed(() => HISTORY_ROWS[selectedHistoryIndex.value] ?? HISTORY_ROWS[0])
const activeFile = computed(() => FILE_ROWS[selectedFileIndex.value] ?? FILE_ROWS[0])
const activeGrep = computed(() => GREP_ROWS[selectedGrepIndex.value] ?? GREP_ROWS[0])
const currentTabRows = computed(() => TAB_GROUPS[activeTabGroup.value])
const activeTabCandidate = computed(
  () => currentTabRows.value[selectedTabIndex.value] ?? currentTabRows.value[0]
)

const historyFooterText = computed(() => {
  if (historyActionHint.value === 'copied') {
    return `Copied #${activeHistory.value.event} to clipboard`
  }
  if (historyActionHint.value === 'fetched') {
    return `Restored #${activeHistory.value.event} via vi-fetch-history`
  }
  return 'Enter: vi-fetch-history · Ctrl-Y: copy'
})

function selectMode(mode: ModeId): void {
  activeMode.value = mode
}

function handleTabKeydown(event: KeyboardEvent, index: number): void {
  if (event.key !== 'ArrowRight' && event.key !== 'ArrowLeft' && event.key !== 'Home' && event.key !== 'End') {
    return
  }
  event.preventDefault()
  let nextIndex = index
  if (event.key === 'ArrowRight') nextIndex = (index + 1) % MODES.length
  else if (event.key === 'ArrowLeft') nextIndex = (index - 1 + MODES.length) % MODES.length
  else if (event.key === 'Home') nextIndex = 0
  else if (event.key === 'End') nextIndex = MODES.length - 1

  const nextMode = MODES[nextIndex]
  activeMode.value = nextMode.id
  const target = (event.currentTarget as HTMLElement | null)?.parentElement?.querySelectorAll<HTMLButtonElement>('[role="tab"]')[nextIndex]
  target?.focus()
}

function selectHistoryRow(index: number): void {
  selectedHistoryIndex.value = index
  historyActionHint.value = 'default'
}

function triggerHistoryCopy(): void {
  historyActionHint.value = 'copied'
  if (typeof navigator !== 'undefined' && navigator.clipboard?.writeText) {
    navigator.clipboard.writeText(activeHistory.value.raw).catch(() => {})
  }
}

function triggerHistoryFetch(): void {
  historyActionHint.value = 'fetched'
}

function toggleCtrlTPreview(): void {
  ctrlTPreviewVisible.value = !ctrlTPreviewVisible.value
}

function switchTabGroup(group: TabGroupId): void {
  activeTabGroup.value = group
  selectedTabIndex.value = 0
}

function toggleTabMark(): void {
  const id = activeTabCandidate.value.id
  if (toggledTabIds.value.includes(id)) {
    toggledTabIds.value = toggledTabIds.value.filter((item) => item !== id)
  } else {
    toggledTabIds.value = [...toggledTabIds.value, id]
  }
}
</script>

<template>
  <div class="fzf-preview-shell">
    <div class="fzf-frame">
      <div class="fzf-header">
        <div class="fzf-title">
          <svg
            class="fzf-title-icon"
            viewBox="0 0 20 20"
            fill="none"
            stroke="currentColor"
            stroke-width="1.8"
            stroke-linecap="round"
            stroke-linejoin="round"
            aria-hidden="true"
          >
            <rect x="2.5" y="3.5" width="15" height="13" rx="2" />
            <path d="m6 8 2.5 2L6 12" />
            <path d="M10.5 12H14" />
          </svg>
          <span>zsh — fzf-unified</span>
        </div>

        <div class="fzf-tablist" role="tablist" aria-label="fzf picker modes">
          <button
            v-for="(tab, idx) in MODES"
            :id="`fzf-tab-${tab.id}`"
            :key="tab.id"
            type="button"
            role="tab"
            class="fzf-tab"
            :class="{ active: activeMode === tab.id }"
            :aria-selected="activeMode === tab.id"
            :aria-controls="`fzf-panel-${tab.id}`"
            :aria-label="tab.ariaLabel"
            :tabindex="activeMode === tab.id ? 0 : -1"
            @click="selectMode(tab.id)"
            @keydown="handleTabKeydown($event, idx)"
          >
            {{ tab.label }}
          </button>
        </div>
      </div>

      <!-- Ctrl-R Mode -->
      <div
        v-if="activeMode === 'ctrl-r'"
        id="fzf-panel-ctrl-r"
        class="fzf-body"
        role="tabpanel"
        aria-labelledby="fzf-tab-ctrl-r"
      >
        <div class="fzf-prompt-row">
          <span class="fzf-prompt-chevron" aria-hidden="true">&gt;</span>
          <span class="fzf-prompt-query">zsh</span>
          <span class="fzf-prompt-cursor" aria-hidden="true" />
          <span class="fzf-match-count">4/1,420</span>
        </div>

        <div class="fzf-list" role="listbox" aria-label="Ctrl-R history matches">
          <button
            v-for="(row, index) in HISTORY_ROWS"
            :key="row.id"
            type="button"
            role="option"
            class="fzf-row fzf-history-row"
            :class="{ selected: selectedHistoryIndex === index }"
            :aria-selected="selectedHistoryIndex === index"
            @click="selectHistoryRow(index)"
          >
            <span class="fzf-pointer" aria-hidden="true">
              {{ selectedHistoryIndex === index ? '▍' : '' }}
            </span>
            <span class="fzf-col-event">{{ row.event }}</span>
            <span class="fzf-col-date">{{ row.date }}</span>
            <span class="fzf-col-time">{{ row.time }}</span>
            <span class="fzf-col-cmd">
              <span v-for="(line, lineIdx) in row.lines" :key="lineIdx" class="fzf-cmd-line">
                {{ line }}
              </span>
            </span>
          </button>
        </div>

        <div class="fzf-footer">
          <span class="fzf-footer-hint" :class="{ active: historyActionHint !== 'default' }">
            {{ historyFooterText }}
          </span>
          <div class="fzf-footer-actions">
            <button
              type="button"
              class="fzf-footer-btn"
              :class="{ active: historyActionHint === 'fetched' }"
              @click="triggerHistoryFetch"
            >
              Enter
            </button>
            <button
              type="button"
              class="fzf-footer-btn"
              :class="{ active: historyActionHint === 'copied' }"
              @click="triggerHistoryCopy"
            >
              Ctrl-Y
            </button>
          </div>
        </div>
      </div>

      <!-- Ctrl-T Mode -->
      <div
        v-else-if="activeMode === 'ctrl-t'"
        id="fzf-panel-ctrl-t"
        class="fzf-body"
        role="tabpanel"
        aria-labelledby="fzf-tab-ctrl-t"
      >
        <div class="fzf-prompt-row">
          <span class="fzf-prompt-chevron" aria-hidden="true">&gt;</span>
          <span class="fzf-prompt-query">fzf</span>
          <span class="fzf-prompt-cursor" aria-hidden="true" />
          <span class="fzf-match-count">4/128</span>
        </div>

        <div class="fzf-split" :class="{ 'no-preview': !ctrlTPreviewVisible }">
          <div class="fzf-list fzf-split-left" role="listbox" aria-label="Ctrl-T file matches">
            <button
              v-for="(item, index) in FILE_ROWS"
              :key="item.id"
              type="button"
              role="option"
              class="fzf-row fzf-file-row"
              :class="{ selected: selectedFileIndex === index }"
              :aria-selected="selectedFileIndex === index"
              @click="selectedFileIndex = index"
            >
              <span class="fzf-pointer" aria-hidden="true">
                {{ selectedFileIndex === index ? '▍' : '' }}
              </span>
              <svg
                v-if="item.kind === 'dir'"
                class="fzf-entry-icon"
                viewBox="0 0 20 20"
                fill="none"
                stroke="currentColor"
                stroke-width="1.8"
                stroke-linecap="round"
                stroke-linejoin="round"
                aria-hidden="true"
              >
                <path d="M2.5 5.5A1.5 1.5 0 0 1 4 4h3.5l1.5 2H16a1.5 1.5 0 0 1 1.5 1.5v7A1.5 1.5 0 0 1 16 16H4a1.5 1.5 0 0 1-1.5-1.5v-9Z" />
              </svg>
              <svg
                v-else
                class="fzf-entry-icon"
                viewBox="0 0 20 20"
                fill="none"
                stroke="currentColor"
                stroke-width="1.8"
                stroke-linecap="round"
                stroke-linejoin="round"
                aria-hidden="true"
              >
                <path d="M5 3.5h6.5L15 7v9.5a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1v-12a1 1 0 0 1 1-1Z" />
                <path d="M11.5 3.5V7H15" />
              </svg>
              <span class="fzf-file-name">{{ item.name }}</span>
            </button>
          </div>

          <div v-if="ctrlTPreviewVisible" class="fzf-split-right" aria-live="polite">
            <div class="fzf-pane-header">
              <span>{{ activeFile.previewHeader }}</span>
              <span class="fzf-pane-meta">{{ activeFile.meta }}</span>
            </div>
            <div class="fzf-pane-lines">
              <div
                v-for="(line, idx) in activeFile.previewLines"
                :key="idx"
                class="fzf-pane-line"
                :class="{ highlighted: line.highlight }"
              >
                <span v-if="line.num" class="fzf-line-num">{{ line.num }}</span>
                <span class="fzf-line-code">{{ line.text }}</span>
              </div>
            </div>
          </div>
        </div>

        <div class="fzf-footer">
          <span class="fzf-footer-hint">
            Ctrl-/: toggle preview ({{ ctrlTPreviewVisible ? '60%' : 'hidden' }})
          </span>
          <button type="button" class="fzf-footer-btn" @click="toggleCtrlTPreview">
            {{ ctrlTPreviewVisible ? 'Hide preview' : 'Show preview' }}
          </button>
        </div>
      </div>

      <!-- Ctrl-G Mode -->
      <div
        v-else-if="activeMode === 'ctrl-g'"
        id="fzf-panel-ctrl-g"
        class="fzf-body"
        role="tabpanel"
        aria-labelledby="fzf-tab-ctrl-g"
      >
        <div class="fzf-prompt-row">
          <span class="fzf-prompt-chevron" aria-hidden="true">&gt;</span>
          <span class="fzf-prompt-query">fzf_history_search</span>
          <span class="fzf-prompt-cursor" aria-hidden="true" />
          <span class="fzf-match-count">4/4</span>
        </div>

        <div class="fzf-grep-preview" aria-live="polite">
          <div class="fzf-pane-header">
            <span>{{ activeGrep.file }}:{{ activeGrep.line }}</span>
            <span class="fzf-pane-meta">rg centered match</span>
          </div>
          <div class="fzf-pane-lines">
            <div
              v-for="ctx in activeGrep.context"
              :key="ctx.num"
              class="fzf-pane-line"
              :class="{ highlighted: ctx.matched }"
            >
              <span class="fzf-line-num">{{ ctx.num }}</span>
              <span class="fzf-line-code">{{ ctx.text || ' ' }}</span>
            </div>
          </div>
        </div>

        <div class="fzf-list fzf-grep-list" role="listbox" aria-label="Ctrl-G ripgrep matches">
          <button
            v-for="(match, index) in GREP_ROWS"
            :key="match.id"
            type="button"
            role="option"
            class="fzf-row fzf-grep-row"
            :class="{ selected: selectedGrepIndex === index }"
            :aria-selected="selectedGrepIndex === index"
            @click="selectedGrepIndex = index"
          >
            <span class="fzf-pointer" aria-hidden="true">
              {{ selectedGrepIndex === index ? '▍' : '' }}
            </span>
            <span class="fzf-grep-loc">{{ match.file }}:{{ match.line }}</span>
            <span class="fzf-grep-snippet">{{ match.snippet }}</span>
          </button>
        </div>

        <div class="fzf-footer">
          <span class="fzf-footer-hint fzf-editor-cmd">
            $EDITOR {{ activeGrep.file }} +{{ activeGrep.line }}
          </span>
          <span class="fzf-footer-meta">Enter: insert command</span>
        </div>
      </div>

      <!-- Tab Mode (fzf-tab) -->
      <div
        v-else
        id="fzf-panel-tab"
        class="fzf-body"
        role="tabpanel"
        aria-labelledby="fzf-tab-tab"
      >
        <div class="fzf-prompt-row">
          <span class="fzf-prompt-chevron" aria-hidden="true">&gt;</span>
          <span class="fzf-prompt-query">eza</span>
          <span class="fzf-prompt-cursor" aria-hidden="true" />
          <span class="fzf-match-count">{{ currentTabRows.length }}/8</span>
        </div>

        <div class="fzf-group-bar" role="group" aria-label="fzf-tab completion groups">
          <span class="fzf-group-arrow" aria-hidden="true">&lt;</span>
          <button
            type="button"
            class="fzf-group-pill"
            :class="{ active: activeTabGroup === 'local-directory' }"
            @click="switchTabGroup('local-directory')"
          >
            local directory
          </button>
          <span class="fzf-group-sep" aria-hidden="true">|</span>
          <button
            type="button"
            class="fzf-group-pill"
            :class="{ active: activeTabGroup === 'options' }"
            @click="switchTabGroup('options')"
          >
            options
          </button>
          <span class="fzf-group-arrow" aria-hidden="true">&gt;</span>
        </div>

        <div class="fzf-split">
          <div class="fzf-list fzf-split-left" role="listbox" aria-label="fzf-tab completion candidates">
            <button
              v-for="(item, index) in currentTabRows"
              :key="item.id"
              type="button"
              role="option"
              class="fzf-row fzf-file-row"
              :class="{ selected: selectedTabIndex === index }"
              :aria-selected="selectedTabIndex === index"
              @click="selectedTabIndex = index"
            >
              <span class="fzf-pointer" aria-hidden="true">
                {{ selectedTabIndex === index ? '▍' : '' }}
              </span>
              <span
                class="fzf-marker"
                :class="{ marked: toggledTabIds.includes(item.id) }"
                aria-hidden="true"
              >
                {{ toggledTabIds.includes(item.id) ? '▍' : '' }}
              </span>
              <span class="fzf-file-name" :class="{ 'is-flag': item.kind === 'flag' }">
                {{ item.label }}
              </span>
            </button>
          </div>

          <div class="fzf-split-right" aria-live="polite">
            <div class="fzf-pane-header">
              <span>{{ activeTabCandidate.previewTitle }}</span>
            </div>
            <div class="fzf-pane-lines">
              <div
                v-for="(line, idx) in activeTabCandidate.previewLines"
                :key="idx"
                class="fzf-pane-line"
              >
                <span class="fzf-line-code">{{ line }}</span>
              </div>
            </div>
          </div>
        </div>

        <div class="fzf-footer">
          <span class="fzf-footer-hint">
            &lt;/&gt;: switch group · Alt-S: toggle ({{ toggledTabIds.length }} marked)
          </span>
          <button type="button" class="fzf-footer-btn" @click="toggleTabMark">Alt-S</button>
        </div>
      </div>
    </div>

    <p class="fzf-caption">Interactive sample · click tabs or rows</p>
  </div>
</template>

<style scoped>
.fzf-preview-shell {
  width: 100%;
  min-width: 0;
  text-align: left;
}

.fzf-frame {
  border: 1px solid var(--vp-c-divider);
  border-radius: 12px;
  background-color: var(--vp-c-bg-alt);
  overflow: hidden;
  font-family: var(--vp-font-family-mono);
  font-size: 12.5px;
  line-height: 1.5;
  color: var(--vp-c-text-1);
}

.fzf-header {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  justify-content: space-between;
  gap: 8px 12px;
  padding: 10px 12px;
  background-color: var(--vp-c-bg-soft);
  border-bottom: 1px solid var(--vp-c-divider);
}

.fzf-title {
  display: inline-flex;
  align-items: center;
  gap: 7px;
  font-size: 12px;
  font-weight: 600;
  color: var(--vp-c-text-2);
  white-space: nowrap;
}

.fzf-title-icon {
  width: 15px;
  height: 15px;
  color: var(--vp-c-brand-1);
  flex-shrink: 0;
}

.fzf-tablist {
  display: inline-flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 4px;
}

.fzf-tab {
  appearance: none;
  border: 1px solid transparent;
  border-radius: 6px;
  padding: 4px 8px;
  background-color: transparent;
  color: var(--vp-c-text-2);
  font-family: var(--vp-font-family-mono);
  font-size: 12px;
  font-weight: 500;
  line-height: 1.2;
  cursor: pointer;
  transition: background-color 0.15s ease, color 0.15s ease, border-color 0.15s ease;
}

.fzf-tab:hover {
  color: var(--vp-c-text-1);
  background-color: var(--vp-c-bg);
}

.fzf-tab.active {
  background-color: color-mix(in srgb, var(--vp-c-brand-1) 14%, transparent);
  border-color: color-mix(in srgb, var(--vp-c-brand-1) 36%, var(--vp-c-divider));
  color: var(--vp-c-brand-1);
  font-weight: 600;
}

.fzf-tab:focus-visible,
.fzf-row:focus-visible,
.fzf-footer-btn:focus-visible,
.fzf-group-pill:focus-visible {
  outline: 2px solid var(--vp-c-brand-1);
  outline-offset: 1px;
}

.fzf-body {
  display: flex;
  flex-direction: column;
  min-height: 248px;
  background-color: var(--vp-c-bg-alt);
}

.fzf-prompt-row {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 12px;
  border-bottom: 1px solid var(--vp-c-divider);
  background-color: var(--vp-c-bg);
}

.fzf-prompt-chevron {
  color: var(--vp-c-brand-1);
  font-weight: 700;
}

.fzf-prompt-query {
  color: var(--vp-c-text-1);
  font-weight: 500;
}

.fzf-prompt-cursor {
  display: inline-block;
  width: 7px;
  height: 14px;
  background-color: var(--vp-c-brand-1);
  opacity: 0.75;
}

.fzf-match-count {
  margin-left: auto;
  font-size: 12px;
  font-variant-numeric: tabular-nums;
  color: var(--vp-c-text-2);
}

.fzf-list {
  display: flex;
  flex-direction: column;
  padding: 4px 0;
  flex: 1 1 auto;
}

.fzf-row {
  appearance: none;
  display: flex;
  align-items: flex-start;
  gap: 8px;
  width: 100%;
  padding: 6px 12px 6px 8px;
  border: 0;
  background: transparent;
  color: var(--vp-c-text-1);
  font-family: var(--vp-font-family-mono);
  font-size: 12px;
  line-height: 1.45;
  text-align: left;
  cursor: pointer;
  transition: background-color 0.12s ease;
}

.fzf-row:hover {
  background-color: color-mix(in srgb, var(--vp-c-text-1) 5%, transparent);
}

.fzf-row.selected {
  background-color: color-mix(in srgb, var(--vp-c-brand-1) 12%, transparent);
}

.fzf-pointer {
  display: inline-block;
  width: 1ch;
  flex-shrink: 0;
  color: var(--vp-c-brand-1);
  font-weight: 700;
}

.fzf-marker {
  display: inline-block;
  width: 0.8ch;
  flex-shrink: 0;
  color: var(--vp-c-warning-1);
  font-weight: 700;
}

.fzf-col-event {
  min-width: 4ch;
  text-align: right;
  font-variant-numeric: tabular-nums;
  color: var(--vp-c-warning-1);
  flex-shrink: 0;
}

.fzf-col-date {
  font-variant-numeric: tabular-nums;
  color: var(--vp-c-text-2);
  flex-shrink: 0;
}

.fzf-col-time {
  font-variant-numeric: tabular-nums;
  color: var(--vp-c-tip-1);
  flex-shrink: 0;
}

.fzf-col-cmd {
  display: flex;
  flex-direction: column;
  min-width: 0;
  flex: 1 1 auto;
  color: var(--vp-c-text-1);
}

.fzf-cmd-line {
  display: block;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.fzf-row.selected .fzf-col-cmd,
.fzf-row.selected .fzf-file-name {
  font-weight: 600;
}

.fzf-split {
  display: grid;
  grid-template-columns: 1fr;
  flex: 1 1 auto;
  min-height: 176px;
}

.fzf-split.no-preview {
  grid-template-columns: 1fr;
}

@media (min-width: 560px) {
  .fzf-split {
    grid-template-columns: 40% minmax(0, 1fr);
  }
}

.fzf-split-left {
  border-bottom: 1px solid var(--vp-c-divider);
}

@media (min-width: 560px) {
  .fzf-split-left {
    border-bottom: 0;
    border-right: 1px solid var(--vp-c-divider);
  }
}

.fzf-split.no-preview .fzf-split-left {
  border-right: 0;
  border-bottom: 0;
}

.fzf-split-right {
  display: flex;
  flex-direction: column;
  min-width: 0;
  background-color: var(--vp-c-bg);
}

.fzf-file-row {
  align-items: center;
}

.fzf-entry-icon {
  width: 14px;
  height: 14px;
  color: var(--vp-c-brand-1);
  flex-shrink: 0;
}

.fzf-file-name {
  min-width: 0;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.fzf-file-name.is-flag {
  color: var(--vp-c-brand-1);
}

.fzf-pane-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
  padding: 5px 10px;
  border-bottom: 1px solid var(--vp-c-divider);
  background-color: var(--vp-c-bg-soft);
  font-size: 11.5px;
  color: var(--vp-c-text-2);
  overflow: hidden;
  white-space: nowrap;
}

.fzf-pane-header > span:first-child {
  overflow: hidden;
  text-overflow: ellipsis;
}

.fzf-pane-meta {
  flex-shrink: 0;
  font-variant-numeric: tabular-nums;
}

.fzf-pane-lines {
  padding: 6px 0;
  overflow-x: auto;
}

.fzf-pane-line {
  display: flex;
  align-items: baseline;
  gap: 8px;
  padding: 1px 10px;
  font-size: 11.5px;
  line-height: 1.5;
  white-space: pre;
}

.fzf-pane-line.highlighted {
  background-color: color-mix(in srgb, var(--vp-c-brand-1) 14%, transparent);
  color: var(--vp-c-text-1);
}

.fzf-line-num {
  min-width: 3ch;
  text-align: right;
  font-variant-numeric: tabular-nums;
  color: var(--vp-c-text-2);
  user-select: none;
}

.fzf-pane-line.highlighted .fzf-line-num {
  color: var(--vp-c-brand-1);
  font-weight: 600;
}

.fzf-line-code {
  color: var(--vp-c-text-1);
}

.fzf-grep-preview {
  border-bottom: 1px solid var(--vp-c-divider);
  background-color: var(--vp-c-bg);
}

.fzf-grep-list {
  padding: 3px 0;
}

.fzf-grep-row {
  align-items: baseline;
}

.fzf-grep-loc {
  color: var(--vp-c-brand-1);
  font-variant-numeric: tabular-nums;
  flex-shrink: 0;
}

.fzf-grep-snippet {
  min-width: 0;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  color: var(--vp-c-text-2);
}

.fzf-group-bar {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 5px 12px;
  border-bottom: 1px solid var(--vp-c-divider);
  background-color: var(--vp-c-bg-soft);
  font-size: 12px;
}

.fzf-group-arrow,
.fzf-group-sep {
  color: var(--vp-c-text-2);
  user-select: none;
}

.fzf-group-pill {
  appearance: none;
  border: 1px solid transparent;
  border-radius: 6px;
  padding: 2px 7px;
  background: transparent;
  color: var(--vp-c-text-2);
  font-family: var(--vp-font-family-mono);
  font-size: 11.5px;
  cursor: pointer;
}

.fzf-group-pill.active {
  background-color: color-mix(in srgb, var(--vp-c-brand-1) 14%, transparent);
  border-color: color-mix(in srgb, var(--vp-c-brand-1) 32%, var(--vp-c-divider));
  color: var(--vp-c-brand-1);
  font-weight: 600;
}

.fzf-footer {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  justify-content: space-between;
  gap: 6px 10px;
  margin-top: auto;
  padding: 7px 12px;
  border-top: 1px solid var(--vp-c-divider);
  background-color: var(--vp-c-bg-soft);
  font-size: 11.5px;
  color: var(--vp-c-text-2);
}

.fzf-footer-hint.active,
.fzf-editor-cmd {
  color: var(--vp-c-brand-1);
  font-weight: 500;
}

.fzf-footer-meta {
  color: var(--vp-c-text-2);
}

.fzf-footer-actions {
  display: inline-flex;
  align-items: center;
  gap: 4px;
}

.fzf-footer-btn {
  appearance: none;
  border: 1px solid var(--vp-c-border);
  border-radius: 6px;
  padding: 2px 7px;
  background-color: var(--vp-c-bg);
  color: var(--vp-c-text-1);
  font-family: var(--vp-font-family-mono);
  font-size: 11px;
  font-weight: 500;
  cursor: pointer;
  transition: border-color 0.15s ease, color 0.15s ease, background-color 0.15s ease;
}

.fzf-footer-btn:hover,
.fzf-footer-btn.active {
  border-color: var(--vp-c-brand-1);
  color: var(--vp-c-brand-1);
  background-color: color-mix(in srgb, var(--vp-c-brand-1) 10%, var(--vp-c-bg));
}

.fzf-caption {
  margin: 10px 2px 0;
  font-family: var(--vp-font-family-base);
  font-size: 0.8125rem;
  line-height: 1.4;
  color: var(--vp-c-text-2);
}

@media (max-width: 479px) {
  .fzf-history-row {
    flex-wrap: wrap;
    row-gap: 2px;
  }

  .fzf-col-cmd {
    flex: 1 0 100%;
    padding-left: calc(1ch + 8px);
  }
}
</style>
