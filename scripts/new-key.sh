#!/usr/bin/env nix
#!nix shell nixpkgs#bash nixpkgs#coreutils nixpkgs#age nixpkgs#sops --command bash

set -euo pipefail

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
mkdir -p $XDG_CONFIG_HOME/sops/age
(umask 0177 && touch $XDG_CONFIG_HOME/sops/age/keys.txt)
age-keygen >> $XDG_CONFIG_HOME/sops/age/keys.txt