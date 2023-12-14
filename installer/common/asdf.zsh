log info "In asdf.zsh!"

ASDF_VERSION="v0.13.1"

if [[ ! -d ~/.asdf ]]; then
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch "$ASDF_VERSION"
fi
