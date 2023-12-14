has_command() {
    command -v $1 &>/dev/null
}

# Use gum to make nice logs.
log() {
    local LEVEL="$1"
    local LINE="$(gum format -t emoji "$2" | xargs)"
    gum log -sl "$LEVEL" --prefix "$funcfiletrace[1]" "$LINE" "${@:3}"
}

go_artifact_name() {
    local PROJECT="$1"
    local EXTENSION="${2:-.tar.gz}"
    printf "%s_%s_%s%s" "$PROJECT" "$GO_OS_NAME" "$ARCH" "$EXTENSION"
}

download_go_program() {
    curl
}

apt_install() {

}

brew_install() {

}

module_exists() {
    local DIR="$1"
    local MODULE_NAME="$2"
    test -f "$DIR/$MODULE_NAME.zsh"
    return "$?"
}

# Runs the given module.
_run_module() {
    local DIR="$1"
    local MODULE_NAME="$2"
    if ! module_exists "$DIR" "$MODULE_NAME"; then
        log error "Attempted to run module that doesn't exist." dir "$DIR" module "$MODULE_NAME"
        return 1
    fi

    log info "Running module." dir "$DIR" module "$MODULE_NAME"
    source "$DIR/$MODULE_NAME.zsh"
    log info "Finished module." dir "$DIR" module "$MODULE_NAME"
}

# Runs a module for the current platform if available, falling back to a common module.
run_module() {
    local MODULE_NAME="$1"

    if module_exists "$OS" "$MODULE_NAME"; then
        _run_module "$OS" "$MODULE_NAME"
    elif module_exists common "$MODULE_NAME"; then
        _run_module common "$MODULE_NAME"
    else
        log warn "Skipped missing module." module "$MODULE_NAME"
    fi
}

# Runs a module only on the given platform.
run_module_on_platform() {
    local TARGET_OS="$1"
    local MODULE_NAME="$2"
    if [[ $TARGET_OS == $OS ]]; then
        run_module "$MODULE_NAME"
    else
        log debug "Skipped module due to wrong platform." target_os "$TARGET_OS" module "$MODULE_NAME"
    fi
}
