source ~/.dotfiles/scripts/functions.sh

source ~/.dotfiles/scripts/bootstrap.sh

source ~/.dotfiles/scripts/completion.sh
source ~/.dotfiles/scripts/plugins.sh

source ~/.dotfiles/scripts/aliases.sh
source ~/.dotfiles/scripts/settings.sh

if [ -f ~/.zshrc_local ]; then
    source ~/.zshrc_local
fi
