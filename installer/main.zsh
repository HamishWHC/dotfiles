#!/usr/bin/env zsh

# cd into script directory.
CALLING_DIR=$(pwd)
cd ${0:a:h}
DOTFILES_DIR=$(realpath $(pwd)/..)

# Run OS detection and populate vars.
source detect-os.zsh
echo "Detected OS:" $OS
echo "Detected Arch:" $ARCH

# Declare helper functions.
source utils.zsh

if ! has_command sudo; then
    echo Aliasing sudo. Are we running in a Docker container?
    sudo() {
        $@
    }
fi

# Install dependencies for the remainder of the script.
source install-deps.zsh

log info "Initialised logger!"

log info "Installing modules..."

# some useful tools
run_module package git fzf bat poetry xh go

# python dependencies
run_module_if_platform macos package openssl readline sqlite3 xz zlib tcl-tk
run_module_if_platform debian package build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev curl \
    libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

# asdf version manager
run_module asdf v0.13.1

# setup asdf plugins
run_module asdf-plugin python latest:3.12
run_module asdf-plugin nodejs latest:20.10

asdf reshim

run_module clear-symlinks
run_module create-ssh-dir
run_module home-symlinks
run_module dotfiles-symlink

log info "Finished module installation."
