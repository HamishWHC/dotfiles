asdf_version=$1

if [[ ! -d ~/.asdf ]]; then
    log info "Missing .asdf directory, cloning..." version $asdf_version
    spin_cmd git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch $asdf_version
fi
