#!/bin/sh

set -euo pipefail

HOST_NAME="$1"
USER_NAME="$2"
if [ -z "$HOST_NAME" ] || [ -z "$USER_NAME" ]; then
  echo "Usage: $0 <host-name> <user-name>"
  exit 1
fi

nix build ".#darwinConfigurations.${HOST_NAME}.config.home-manager.users.${USER_NAME}.home.activationPackage"