# Use colors in coreutils utilities output
alias ls='ls --color=auto'
alias grep='grep --color'

# ls aliases
alias ll='ls -lah'
alias la='ls -A'
alias l='ls'

# Aliases to protect against overwriting
alias cp='cp -i'
alias mv='mv -i'

# Restart shell.
alias restart='exec "$SHELL"'

# Use bat instead of cat/man.
alias cat='bat --paging=never'

# Make bat used for help.
alias -g -- --help='--help 2>&1 | bat --language=help --style=plain'

alias docker-ka='docker kill $(docker ps -q)'
alias docker-kra='docker rm -f $(docker ps -aq)'

# Update dotfiles
dfu() {
    (
        cd ~/.dotfiles && git pull --ff-only && ./install -q
    )
}

hist() {
    local COMMAND="$(sed -r "s/^: [0-9]+:[0-9]+;//g" ~/.zsh_history | fzf --tac)"
    if [ "$COMMAND" != "" ]; then
        echo $COMMAND | tr -d '\n' | pbcopy
        echo "Copied:" $COMMAND
    fi
}

# cd to git root directory
alias cdgr='cd "$(git root)"'

listening() {
    # The grep . is to make it return faster. IDK why it works lol.
    if [ "$#" -eq 0 ]; then
        sudo lsof -i -P | grep . | awk 'NR == 1 || /LISTEN/'
        return 1
    fi
    if [ "$#" -eq 1 ]; then
        sudo lsof -i -P | grep . | awk 'NR == 1 || (/LISTEN/ && /'"$1"'/)'
        return 0
    fi

    echo "Usage: listening [port]"
    return 1
}

# Create a directory and cd into it
mcd() {
    mkdir "${1}" && cd "${1}"
}

# Go up [n] directories
up() {
    local cdir="$(pwd)"
    if [[ "${1}" == "" ]]; then
        cdir="$(dirname "${cdir}")"
    elif ! [[ "${1}" =~ ^[0-9]+$ ]]; then
        echo "Error: argument must be a number"
    elif ! [[ "${1}" -gt "0" ]]; then
        echo "Error: argument must be positive"
    else
        for ((i = 0; i < ${1}; i++)); do
            local ncdir="$(dirname "${cdir}")"
            if [[ "${cdir}" == "${ncdir}" ]]; then
                break
            else
                cdir="${ncdir}"
            fi
        done
    fi
    cd "${cdir}"
}
