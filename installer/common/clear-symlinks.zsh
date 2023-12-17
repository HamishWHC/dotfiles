clear_symlink() {
    file=$1
    real=$(realpath -m $1)
    if [[ $real == $DOTFILES_DIR* ]]; then
        log info "Removing broken symlink." path $file realpath $real
        rm $file
    else
        log warn "Found broken symlink pointing outside of ~/.dotfiles." path $file realpath $real
    fi
}

clear_symlinks() {
    local dir=$1
    log info "Finding broken symlinks..." dir $dir recursive false
    for file in $dir/*(-@ND); do
        clear_symlink $file
    done
}

clear_symlinks_recursive() {
    local dir=$1
    log info "Finding broken symlinks..." dir $dir recursive true
    for file in $dir/**/*(-@ND); do
        clear_symlink $file
    done
}

clear_symlinks ~
clear_symlinks_recursive ~/.ssh
