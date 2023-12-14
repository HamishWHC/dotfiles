#!/usr/bin/env zsh

# cd into script directory.
ORIGINAL_DIR="$(pwd)"
cd ${0:a:h}

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

run_module asdf

run_module symlinking

log info "Finished module installation."
