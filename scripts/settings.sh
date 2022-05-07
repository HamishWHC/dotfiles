export EDITOR=code

# Starship Shell
eval "$(starship init zsh)"

source $HOME/.dotfiles/scripts/unsw.sh

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
