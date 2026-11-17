# Entry point for the ooodnakov-fzf Oh My Zsh plugin. The plugin root is
# resolved here so every sourced file can locate its own assets (vendor tree,
# lib/) regardless of how the plugin is loaded (Oh My Zsh or manually).
0="${${ZERO:-${0:#$ZSH_ARGZERO}}:-${(%):-%N}}"
0="${${(M)0:#/*}:-$PWD/$0}"
source "${0:A:h}/ooodnakov-fzf.zsh"