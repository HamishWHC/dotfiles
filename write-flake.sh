#!/bin/sh

set -euo pipefail
cd "$(dirname "$0")"

nix run ".#write-flake"