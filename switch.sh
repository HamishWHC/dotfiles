#!/bin/sh

set -euo pipefail
cd "$(dirname "$0")"

HOST_NAME="$1"
if [ -z "$HOST_NAME" ]; then
  echo "Usage: $0 <host-name>"
  exit 1
fi

NIX_PATH="$(which nix)"
sudo $NIX_PATH run nix-darwin#darwin-rebuild -- switch --flake ".#${HOST_NAME}"