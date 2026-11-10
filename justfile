set default-list
set lazy

import '.just-hosts.just'
import 'lima/recipes.just'
import 'utm/recipes.just'

system_config_dir := x'${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles'
default_host := if path_exists(system_config_dir / "host") == "true" { trim(read(system_config_dir / "host")) } else { "" }
default_username := if path_exists(system_config_dir / "username") == "true" { trim(read(system_config_dir / "username")) } else { "" }

[doc("check that the nix code is syntactically correct and is not completely insane")]
check:
    nix flake check

[doc("updates flake.lock with the latest matching versions")]
update:
    nix flake update

[doc("counts the line of code in this project")]
cloc:
    @# Excludes automator workflows and plists, because 40k lines of XML is not representative of this repo.
    cloc --vcs=git --exclude-ext=wflow,plist

# Build / Switch

[macos]
[doc("builds a Darwin system configuration")]
[group("Build / Switch")]
[arg("host", pattern=darwin_hosts, help="a hostname in the flake's darwinConfigurations")]
[script]
build-system host=default_host:
    host={{ quote(host) }}
    rm -rf result
    nix build --option accept-flake-config true ".#darwinConfigurations.${host}.system"

[linux]
[doc("builds a NixOS system configuration")]
[group("Build / Switch")]
[arg("host", pattern=nixos_hosts, help="a hostname in the flake's nixosConfigurations")]
[script]
build-system host=default_host:
    host={{ quote(host) }}
    rm -rf result
    nix build --option accept-flake-config true --out-link result \
        "path:.#nixosConfigurations.${host}.config.system.build.toplevel"

[macos]
[doc("builds a Darwin home activation package")]
[group("Build / Switch")]
[arg("host", pattern=darwin_hosts, help="a hostname in the flake's darwinConfigurations")]
[arg("username", help="a user for the given host")]
[script]
build-home host=default_host username=default_username:
    host={{ quote(host) }}
    username={{ quote(username) }}
    username="$(scripts/resolve-username.sh "$host" "$username" {{ quote(host_users) }})"
    rm -rf result
    nix build --option accept-flake-config true ".#darwinConfigurations.${host}.config.home-manager.users.${username}.home.activationPackage"

[linux]
[doc("builds a NixOS home activation package")]
[group("Build / Switch")]
[arg("host", pattern=nixos_hosts, help="a hostname in the flake's nixosConfigurations")]
[arg("username", help="a user for the given host")]
[script]
build-home host=default_host username=default_username:
    host={{ quote(host) }}
    username={{ quote(username) }}
    username="$(scripts/resolve-username.sh "$host" "$username" {{ quote(host_users) }})"
    rm -rf result
    nix build --option accept-flake-config true --out-link result \
        "path:.#nixosConfigurations.${host}.config.home-manager.users.${username}.home.activationPackage"

[macos]
[doc("applies a Darwin configuration to the local system")]
[group("Build / Switch")]
[arg("host", pattern=darwin_hosts, help="a hostname in the flake's darwinConfigurations")]
switch host=default_host:
    sudo -H nix run "nix-darwin#darwin-rebuild" -- switch --option accept-flake-config true --flake ".#{{ host }}"

[linux]
[doc("applies a NixOS configuration to the local system")]
[group("Build / Switch")]
[arg("host", pattern=nixos_hosts, help="a hostname in the flake's nixosConfigurations")]
switch host=default_host:
    sudo nixos-rebuild switch --option accept-flake-config true --flake "path:.#{{ host }}"

# Code Generation

[doc("updates flake.nix with input changes")]
[group("Code Generation")]
write-flake:
    nix run ".#write-flake"

[doc("updates the cached host and username choices from the flake")]
[group("Code Generation")]
update-hosts:
    scripts/update-hosts.py

# Secrets

[doc("generate new device key")]
[group("Secrets")]
new-key:
    scripts/new-key.sh

[doc("syncs secrets with changed device keys")]
[group("Secrets")]
update-keys:
    sops updatekeys secrets/*

[doc("rotates data keys - good to do regularly")]
[group("Secrets")]
rotate-data-keys:
    sops rotate -i secrets/*
