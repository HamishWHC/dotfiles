#!/usr/bin/env bash

cd "$(dirname "$0")"

if ! command -v sudo &>/dev/null; then
    sudo() {
        $@
    }
fi

if ! command -v zsh &>/dev/null; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # Mac OSX already has zsh preloaded, do nothing!
        echo -n
    elif [[ "$OSTYPE" == "linux-gnu"* && -f "/etc/debian_version" ]]; then
        # Install zsh.
        sudo apt update
        sudo apt install zsh -y
        chsh -s $(which zsh)
    fi
fi

cd installer
zsh main.zsh
