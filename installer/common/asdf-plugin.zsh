plugin=$1
log info "Adding asdf plugin..." plugin $plugin
spin_cmd asdf plugin add $plugin

first=${2:-}
for version in ${@:2}; do
    spin_cmd asdf install $plugin $version
done

asdf global $plugin $first
