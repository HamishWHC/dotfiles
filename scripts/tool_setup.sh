# Homebrew completions
eval "$(/opt/homebrew/bin/brew shellenv)"
FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"

# zsh autocompletion
autoload -U compinit
compinit

# asdf
. $(brew --prefix asdf)/libexec/asdf.sh && asdf reshim

# fzf-tab for nice autocompletion interface
source $HOME/.dotfiles/plugins/fzf-tab/fzf-tab.plugin.zsh

# z navigator
. $HOME/.dotfiles/plugins/z/z.sh

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# Set editor to nano for things like git messages and similar.
export EDITOR=nano

# Starship Shell
eval "$(starship init zsh)"

source $HOME/.dotfiles/scripts/sfs.sh
