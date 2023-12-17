target=~/.dotfiles

if [[ -e $target ]]; then
    if [[ -L $target ]]; then
        points_to=$(realpath $(readlink $target_file))
        if [[ $points_to == $file ]]; then
            log debug "$target already exists, skipping." source $DOTFILES_DIR target $target
        else
            log warn "$target already exists, but points elsewhere." source $DOTFILES_DIR target $target points_to $points_to
        fi
    else
        log warn "$target already exists and is not a symlink." source $DOTFILES_DIR target $target
    fi
else
    log info "Creating $target symlink." source $DOTFILES_DIR target $target
    ln -s $DOTFILES_DIR $target
fi
