import { defineConfig } from 'vitepress'

export default defineConfig({
  title: 'zsh-fzf-unified',
  description:
    'One zsh plugin that owns every fzf surface: Ctrl-R history search, Ctrl-T / Alt-C pickers, Ctrl-G ripgrep, fzf-tab completion and hybrid Up/Down arrows.',
  base: '/zsh-fzf-unified/',
  cleanUrls: true,

  head: [
    ['link', { rel: 'icon', href: '/zsh-fzf-unified/logo.svg', type: 'image/svg+xml' }],
    [
      'script',
      { id: 'check-color-theme' },
      "(()=>{try{const t=localStorage.getItem('ooodnakov-docs-theme');if(t&&/^(solarized|gruvbox|catppuccin|nord|tokyo-night|dracula|rose-pine)$/.test(t))document.documentElement.setAttribute('data-theme',t)}catch{}})()",
    ],
  ],

  themeConfig: {
    logo: '/logo.svg',

    search: {
      provider: 'local',
    },

    socialLinks: [
      { icon: 'github', link: 'https://github.com/ooodnakov/zsh-fzf-unified' },
    ],

    nav: [
      { text: 'Guide', link: '/guide/why' },
      { text: 'Keybindings', link: '/guide/keybindings' },
      { text: 'Previews', link: '/guide/previews' },
      { text: 'Configuration', link: '/config/behavior' },
      { text: 'Reference', link: '/reference/architecture' },
    ],

    sidebar: [
      {
        text: 'Getting Started',
        items: [
          { text: 'Why Unified', link: '/guide/why' },
          { text: 'Install & Requirements', link: '/guide/install' },
        ],
      },
      {
        text: 'Features & Surfaces',
        items: [
          { text: 'Keybindings Cheatsheet', link: '/guide/keybindings' },
          { text: 'Ctrl-R History Search', link: '/guide/history-search' },
          { text: 'Previews & fzf-tab Contexts', link: '/guide/previews' },
        ],
      },
      {
        text: 'Configuration',
        items: [
          { text: 'Behavior & History Options', link: '/config/behavior' },
          { text: 'Column Colors (SGR)', link: '/config/colors' },
          { text: 'Global fzf Options', link: '/config/fzf-options' },
        ],
      },
      {
        text: 'Reference',
        items: [
          { text: 'Architecture & Precedence', link: '/reference/architecture' },
          { text: 'Third-Party & License', link: '/reference/third-party' },
        ],
      },
    ],

    editLink: {
      pattern: 'https://github.com/ooodnakov/zsh-fzf-unified/edit/main/site/:path',
      text: 'Edit this page on GitHub',
    },

    footer: {
      message: 'Released under the MIT License.',
      copyright: 'Copyright © Aleksandr Odnakov',
    },
  },
})
