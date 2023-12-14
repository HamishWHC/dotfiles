OS=""
ARCH="$(uname -m)"
GO_OS_NAME=""

if [[ "$OSTYPE" == "darwin"* ]]; then
    # Mac OSX already has zsh preloaded, do nothing!
    OS="macos"
    GO_OS_NAME="Darwin"
elif [[ "$OSTYPE" == "linux-gnu"* && -f "/etc/debian_version" ]]; then
    OS="debian"
    GO_OS_NAME="Linux"
else
    echo "Haven't accounted for this OS, this was built for macOS and Debian-based Linux distros."
    exit 1
fi
