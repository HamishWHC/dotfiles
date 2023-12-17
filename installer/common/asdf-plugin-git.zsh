plugin=$1
repo=$2
log info "Adding asdf plugin from git..." plugin $plugin repo $repo
spin_cmd asdf plugin add $plugin $repo

first=${3:-}
for version in ${@:3}; do
    spin_cmd asdf install $plugin $version
done

asdf global $plugin $first
