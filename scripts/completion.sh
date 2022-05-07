# Homebrew completions
eval "$(/opt/homebrew/bin/brew shellenv)"
FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"

# zsh autocompletion
autoload -U compinit
compinit

# 1password completion
eval "$(op completion zsh)"
compdef _op op

# pipenv completion
eval "$(_PIPENV_COMPLETE=zsh_source pipenv)"
