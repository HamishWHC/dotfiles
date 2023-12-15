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

run_module package git fzf bat poetry
run_module_if_platform macos package openssl readline sqlite3 xz zlib tcl-tk

run_module asdf v0.13.1

run_module asdf-plugin python
asdf global python latest:3.12

run_module asdf-plugin nodejs
asdf global nodejs latest:20

asdf reshim

run_module clear-symlinks
run_module create-ssh-dir
run_module add-home-symlinks

log info "Finished module installation."
