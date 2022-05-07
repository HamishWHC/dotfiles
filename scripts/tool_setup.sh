# Homebrew completions
eval "$(/opt/homebrew/bin/brew shellenv)"
FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"

# zsh autocompletion
autoload -U compinit
compinit

# asdf
. $(brew --prefix asdf)/libexec/asdf.sh && asdf reshim

# pipenv completion
eval "$(_PIPENV_COMPLETE=zsh_source pipenv)"

# fzf-tab for nice autocompletion interface
source $HOME/.dotfiles/plugins/fzf-tab/fzf-tab.plugin.zsh

# z navigator
. $HOME/.dotfiles/plugins/z/z.sh

# Set editor to nano for things like git messages and similar.
export EDITOR=nano

# Starship Shell
eval "$(starship init zsh)"

source $HOME/.dotfiles/scripts/unsw.sh
