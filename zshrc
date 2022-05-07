source ~/.dotfiles/scripts/functions.sh
source ~/.dotfiles/scripts/bootstrap.sh
source ~/.dotfiles/scripts/tool_setup.sh
source ~/.dotfiles/scripts/aliases.sh

if [ -f ~/.zshrc_local ]; then
    source ~/.zshrc_local
fi
