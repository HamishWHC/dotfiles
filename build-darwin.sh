#!/bin/sh

set -euo pipefail

HOST_NAME="$1"
if [ -z "$HOST_NAME" ]; then
  echo "Usage: $0 <host-name>"
  exit 1
fi

rm -rf result
nix build ".#darwinConfigurations.${HOST_NAME}.system"