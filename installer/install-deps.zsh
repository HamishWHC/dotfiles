# TODO: See if I can install/download gum using curl/wget, so I can install brew in a module.

# On macos, we need brew installed to install gum.
if [[ $OS == "macos" ]]; then
    if ! has_command brew; then
        echo Installing brew...
        curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash
        echo Installed brew!
    else
        echo Found existing brew installation.
    fi
fi

# Use gum for nice TUI features and logging.
if ! has_command gum; then
    echo Installing gum...
    if [[ $OS == "macos" ]]; then
        brew install gum
    elif [[ $OS == "debian" ]]; then
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
        echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
        sudo apt update && sudo apt install gum
    fi
    echo Installed gum!
else
    echo Found existing gum installation.
fi
