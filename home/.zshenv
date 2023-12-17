export EDITOR=nano
export BAT_PAGER="less -RF"
export PAGER="bat"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

. "$HOME/.cargo/env"

[[ -f ~/.zshenv_local ]] && source ~/.zshenv_local
