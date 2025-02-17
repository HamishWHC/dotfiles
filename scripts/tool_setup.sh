# Homebrew completions
eval "$(/opt/homebrew/bin/brew shellenv)"
FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"

# zsh autocompletion
# autoload bashcompinit && bashcompinit
# autoload -U compinit
# compinit

# fzf-tab for nice autocompletion interface
source $HOME/.dotfiles/plugins/fzf-tab/fzf-tab.plugin.zsh

# z navigator
. $HOME/.dotfiles/plugins/z/z.sh

# completions for aliases
# . $HOME/.dotfiles/plugins/complete-alias/complete_alias
