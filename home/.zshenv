export EDITOR=nano
export BAT_PAGER="less -RF"
export PAGER="bat"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

[[ -f ~/.zshenv_local ]] && source ~/.zshenv_local
