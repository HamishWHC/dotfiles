set default-list
set lazy

import '.just-hosts.just'

system_config_dir := x'${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles'
default_host := if path_exists(system_config_dir / "host") == "true" { trim(read(system_config_dir / "host")) } else { "" }
default_username := if path_exists(system_config_dir / "username") == "true" { trim(read(system_config_dir / "username")) } else { "" }
lima_username := env("USER")
lima_guest_config_dir := "/home/" + lima_username + "/dotfiles"

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
    nix build ".#darwinConfigurations.${host}.system"

[linux]
[doc("builds a NixOS system configuration")]
[group("Build / Switch")]
[arg("host", pattern=nixos_hosts, help="a hostname in the flake's nixosConfigurations")]
[script]
build-system host=default_host:
    host={{ quote(host) }}
    rm -rf result
    nix build --out-link result \
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
    nix build ".#darwinConfigurations.${host}.config.home-manager.users.${username}.home.activationPackage"

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
    nix build --out-link result \
        "path:.#nixosConfigurations.${host}.config.home-manager.users.${username}.home.activationPackage"

[macos]
[doc("applies a Darwin configuration to the local system")]
[group("Build / Switch")]
[arg("host", pattern=darwin_hosts, help="a hostname in the flake's darwinConfigurations")]
switch host=default_host:
    sudo nix run "nix-darwin#darwin-rebuild" -- switch --flake ".#{{ host }}"

[linux]
[doc("applies a NixOS configuration to the local system")]
[group("Build / Switch")]
[arg("host", pattern=nixos_hosts, help="a hostname in the flake's nixosConfigurations")]
switch host=default_host:
    sudo nixos-rebuild switch --flake "path:.#{{ host }}"

# Lima NixOS

[doc("prints the current worktree's Lima instance name")]
[group("Lima NixOS")]
[arg("host", pattern=lima_nixos_hosts, help="the shortened NixOS host to run")]
lima-name host:
    @scripts/lima-instance-name.sh {{ quote(host) }}

[doc("creates or starts the current worktree's NixOS Lima VM")]
[group("Lima NixOS")]
[arg("host", pattern=lima_nixos_hosts, help="the shortened NixOS host to run")]
[script]
lima-start host:
    host={{ quote(host) }}
    instance="$(scripts/lima-instance-name.sh "$host")"
    project_dir="$(pwd -P)"
    username={{ quote(lima_username) }}
    guest_home="/home/${username}"
    guest_config_dir="${guest_home}/dotfiles"

    jq --null-input \
        --arg username "$username" \
        --arg hostPath "$project_dir" \
        '{ username: $username, hostPath: $hostPath }' \
        > lima/runtime.json

    if limactl list --quiet | grep -Fxq "$instance"; then
        limactl start "$instance"
        exit
    fi

    project_dir_json="$(jq --null-input --arg value "$project_dir" '$value')"
    username_json="$(jq --null-input --arg value "$username" '$value')"
    guest_home_json="$(jq --null-input --arg value "$guest_home" '$value')"
    guest_config_dir_json="$(jq --null-input --arg value "$guest_config_dir" '$value')"
    set_expression="
        .mounts[0].location = ${project_dir_json}
        | .mounts[0].mountPoint = ${guest_config_dir_json}
        | .user.name = ${username_json}
        | .user.home = ${guest_home_json}
    "
    limactl start --yes \
        --name "$instance" \
        --set "$set_expression" \
        lima/nixos.yaml

[doc("opens a shell in the current worktree's NixOS Lima VM")]
[group("Lima NixOS")]
[arg("host", pattern=lima_nixos_hosts, help="the shortened NixOS host to run")]
[script]
lima-shell host:
    host={{ quote(host) }}
    just lima-start "$host"
    instance="$(scripts/lima-instance-name.sh "$host")"
    exec limactl shell --workdir {{ quote(lima_guest_config_dir) }} "$instance"

[doc("builds the mounted worktree's NixOS system configuration in its Lima VM")]
[group("Lima NixOS")]
[arg("host", pattern=lima_nixos_hosts, help="the shortened NixOS host configuration to build")]
[script]
lima-build-system host:
    host={{ quote(host) }}
    just lima-start "$host"
    instance="$(scripts/lima-instance-name.sh "$host")"
    limactl shell --workdir {{ quote(lima_guest_config_dir) }} "$instance" -- \
        nix shell --inputs-from "path:." \
            "nixpkgs-unstable#just" "nixpkgs#jq" \
            --command just build-system "lima-nixos-${host}"

[doc("builds the mounted worktree's home configuration in its Lima VM")]
[group("Lima NixOS")]
[arg("host", pattern=lima_nixos_hosts, help="the shortened NixOS host configuration to build")]
[script]
lima-build-home host:
    host={{ quote(host) }}
    just lima-start "$host"
    instance="$(scripts/lima-instance-name.sh "$host")"
    limactl shell --workdir {{ quote(lima_guest_config_dir) }} "$instance" -- \
        nix shell --inputs-from "path:." \
            "nixpkgs-unstable#just" "nixpkgs#jq" \
            --command just build-home "lima-nixos-${host}" {{ quote(lima_username) }}

[doc("applies the mounted worktree to its NixOS Lima VM")]
[group("Lima NixOS")]
[arg("host", pattern=lima_nixos_hosts, help="the shortened NixOS host configuration to apply")]
[script]
lima-switch host:
    host={{ quote(host) }}
    just lima-start "$host"
    instance="$(scripts/lima-instance-name.sh "$host")"
    limactl shell --workdir {{ quote(lima_guest_config_dir) }} "$instance" -- \
        nix shell --inputs-from "path:." \
            "nixpkgs-unstable#just" "nixpkgs#jq" \
            --command just switch "lima-nixos-${host}"

[doc("stops the current worktree's NixOS Lima VM")]
[group("Lima NixOS")]
[arg("host", pattern=lima_nixos_hosts, help="the shortened NixOS host VM to stop")]
[script]
lima-stop host:
    host={{ quote(host) }}
    instance="$(scripts/lima-instance-name.sh "$host")"

    if ! limactl list --quiet | grep -Fxq "$instance"; then
        echo "Lima instance '$instance' does not exist."
        exit
    fi

    limactl stop "$instance"

[doc("stops every running dotfiles NixOS Lima VM")]
[group("Lima NixOS")]
[script]
lima-stop-all:
    found=false
    for instance in $(limactl list --quiet --filter '.status == "Running"'); do
        case "$instance" in
            dotfiles-lima-nixos-*)
                found=true
                limactl stop "$instance"
                ;;
        esac
    done

    if ! "$found"; then
        echo "No running dotfiles Lima instances exist."
    fi

[doc("forcibly deletes the current worktree's NixOS Lima VM")]
[group("Lima NixOS")]
[arg("host", pattern=lima_nixos_hosts, help="the shortened NixOS host VM to delete")]
[script]
lima-delete host:
    host={{ quote(host) }}
    instance="$(scripts/lima-instance-name.sh "$host")"

    if ! limactl list --quiet | grep -Fxq "$instance"; then
        echo "Lima instance '$instance' does not exist."
        exit
    fi

    limactl delete --force "$instance"

[doc("forcibly deletes every dotfiles NixOS Lima VM")]
[group("Lima NixOS")]
[script]
lima-delete-all:
    found=false
    for instance in $(limactl list --quiet); do
        case "$instance" in
            dotfiles-lima-nixos-*)
                found=true
                limactl delete --force "$instance"
                ;;
        esac
    done

    if ! "$found"; then
        echo "No dotfiles Lima instances exist."
    fi

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
