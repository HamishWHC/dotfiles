has_command() {
    command -v $1 &>/dev/null
}

# Use gum to make nice logs.
log() {
    local level=$1
    local line=$(gum format -t emoji $2 | xargs)
    gum log -sl $level --prefix $funcfiletrace[1] $line ${@:3}
}

spin() {
    local title=$1
    gum spin --spinner line --title $title -- ${@:2}
}

spin_cmd() {
    local title="Waiting for $@..."
    gum spin --spinner line --title $title -- $@
}

install_package() {
    local package_name_idx=$1
    local manager=$3
    local command=${@:3}
    local package_names=${@:$package_name_idx}

    log info "Installing $package_names via $manager..." packages $package_names command "$command"
    spin_cmd ${@:3}

    local retval=$?
    if [[ $retval == 0 ]]; then
        log info "Installed $package_names via brew." packages $package_names command "$command"
    else
        log error "Failed to install $package_names via $manager." packages $package_names command "$command"
    fi
    return $retval
}

go_artifact_name() {
    local project=$1
    local extension=${2:-.tar.gz}
    printf "%s_%s_%s%s" $project $GO_OS_NAME $ARCH $extension
}

download_go_program() {
    curl
}

module_exists() {
    local dir=$1
    local module_name=$2
    test -f $dir/$module_name.zsh
}

# Runs the given module.
_run_module() {
    local dir=$1
    local module_name=$2
    if ! module_exists $dir $module_name; then
        log error "Attempted to run module that doesn't exist." dir $dir module $module_name
        return 1
    fi

    log debug "Running module." dir $dir module $module_name
    source $dir/$module_name.zsh ${@:3}
    local retval=$?
    log debug "Finished module." dir $dir module $module_name
    return $retval
}

# Runs a module for the current platform if available, falling back to a common module.
run_module() {
    local module_name=$1

    if module_exists $OS $module_name; then
        _run_module $OS $module_name ${@:2}
    elif module_exists common $module_name; then
        _run_module common $module_name ${@:2}
    else
        log warn "Skipped missing module." module $module_name
    fi
}

# Runs a module only on the given platform.
run_module_if_platform() {
    local target_os=$1
    local module_name=$2
    if [[ $target_os == $OS ]]; then
        run_module $module_name ${@:3}
    else
        log debug "Skipped module due to wrong platform." target_os $target_os module $module_name
    fi
}
