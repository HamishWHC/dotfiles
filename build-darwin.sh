#!/bin/sh

set -euo pipefail

local HOST_NAME="$1"
if [ -z "$HOST_NAME" ]; then
  echo "Usage: $0 <host-name>"
  exit 1
fi

nix build ".#darwinConfigurations.${HOST_NAME}.system"