dir=$(realpath ../home)
target_dir=$(realpath ~)

for file in $dir/**/*(.ND); do
    target_file=$(echo $target_dir/${file#"$dir"} | tr -s /)
    log debug "Found file for symlinking..." source $file target $target_file

    if [[ -e $target_file ]]; then
        if [[ -L $target_file ]]; then
            points_to=$(realpath $(readlink $target_file))
            if [[ $points_to == $file ]]; then
                log debug "$target_file already exists, skipping." source $file target $target_file
            else
                log warn "$target_file already exists, but points elsewhere." source $file target $target_file points_to $points_to
            fi
        else
            log warn "$target_file already exists and is not a symlink." source $file target $target_file
        fi
    else
        log info "Creating $target_file symlink." source $file target $target_file
        ln -s $file $target_file
    fi
done
