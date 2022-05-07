# Homebrew completions
eval "$(/opt/homebrew/bin/brew shellenv)"
FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"

# zsh autocompletion
autoload -U compinit
compinit

# pipenv completion
eval "$(_PIPENV_COMPLETE=zsh_source pipenv)"
