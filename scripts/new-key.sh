#!/usr/bin/env nix
#!nix shell nixpkgs#bash nixpkgs#coreutils nixpkgs#age nixpkgs#age-plugin-se nixpkgs#gum --command bash

set -euo pipefail

location="${1:-}"

if [[ -z "$location" ]]; then
    options="file file-pq "
    system="$(uname -s)"
    if [[ "$system" == "Darwin" ]]; then
        options+="secure-enclave"
    fi
    location="$(gum choose --select-if-one $options)"
fi

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
mkdir -p $XDG_CONFIG_HOME/sops/age
(umask 0177 && touch $XDG_CONFIG_HOME/sops/age/keys.txt)

identity=""
if [[ "$location" == "file" ]]; then
    identity="$(age-keygen 2> /dev/null)"
elif [[ "$location" == "file-pq" ]]; then
    identity="$(age-keygen --pq 2> /dev/null)"
elif [[ "$location" == "secure-enclave" ]]; then
    identity="$(age-plugin-se keygen --access-control any-biometry-or-passcode --recipient-type tag)"
else
    >&2 echo "invalid key location"
    exit 1
fi

printf "%s\n" "$identity" \
| tee -a $XDG_CONFIG_HOME/sops/age/keys.txt \
| grep --color=never "#"