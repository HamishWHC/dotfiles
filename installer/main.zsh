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
run_module package git fzf bat xh kubectx

# python dependencies, also just nice to have
run_module_if_platform macos package openssl readline sqlite3 xz zlib tcl-tk
run_module_if_platform debian package build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev curl \
    libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

# Install kubectl on macOS. Linux is a pain.
run_module_if_platform macos package kubectl

run_module clear-symlinks
run_module create-ssh-dir
run_module create-config-dirs
run_module home-symlinks
run_module dotfiles-symlink

log info "Finished module installation."
