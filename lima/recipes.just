lima_username := env("USER")
lima_guest_config_dir := "/home/" + lima_username + "/dotfiles"

# Lima NixOS

[doc("prints the current worktree's Lima instance name")]
[group("Lima NixOS")]
[arg("host", pattern=lima_nixos_hosts, help="the shortened NixOS host to run")]
lima-name host:
    @scripts/vm-instance-name.sh lima {{ quote(host) }}

[doc("creates or starts the current worktree's NixOS Lima VM")]
[group("Lima NixOS")]
[arg("host", pattern=lima_nixos_hosts, help="the shortened NixOS host to run")]
[script]
lima-start host:
    host={{ quote(host) }}
    instance="$(scripts/vm-instance-name.sh lima "$host")"
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
    instance="$(scripts/vm-instance-name.sh lima "$host")"
    exec limactl shell --workdir {{ quote(lima_guest_config_dir) }} "$instance"

[doc("builds the mounted worktree's NixOS system configuration in its Lima VM")]
[group("Lima NixOS")]
[arg("host", pattern=lima_nixos_hosts, help="the shortened NixOS host configuration to build")]
[script]
lima-build-system host:
    host={{ quote(host) }}
    just lima-start "$host"
    instance="$(scripts/vm-instance-name.sh lima "$host")"
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
    instance="$(scripts/vm-instance-name.sh lima "$host")"
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
    instance="$(scripts/vm-instance-name.sh lima "$host")"
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
    instance="$(scripts/vm-instance-name.sh lima "$host")"

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
    instance="$(scripts/vm-instance-name.sh lima "$host")"

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
