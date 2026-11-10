utm_username := env("USER")
utm_guest_config_dir := "/home/" + utm_username + "/dotfiles"
utm_ssh_key := x'${XDG_DATA_HOME:-$HOME/.local/share}/dotfiles/utm_ed25519'
utmctl := "/Applications/UTM.app/Contents/MacOS/utmctl"
utm_ssh_options := "-i " + quote(utm_ssh_key) + " -o IdentitiesOnly=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR"
utm_memory := "8192"
utm_cpus := "4"
# UTM can't resize Wayland guests to fit the window (that needs the X11-only
# SPICE agent), so the display is fixed. With native resolution on, this opens
# a 1280x800-point window; the guest's 1.25 scale gives a 2048x1280 workspace.
utm_display_width := "2560"
utm_display_height := "1600"

# UTM NixOS

[doc("prints the current worktree's UTM VM name")]
[group("UTM NixOS")]
[arg("host", pattern=utm_nixos_hosts, help="the shortened NixOS host to run")]
utm-name host:
    @scripts/vm-instance-name.sh utm {{ quote(host) }}

[private]
[script]
utm-runtime:
    key={{ quote(utm_ssh_key) }}
    if [ ! -f "$key" ]; then
        mkdir -p "$(dirname "$key")"
        ssh-keygen -q -t ed25519 -N "" -C "dotfiles-utm" -f "$key"
    fi

    jq --null-input \
        --arg username {{ quote(utm_username) }} \
        --arg sshPublicKey "$(cat "$key.pub")" \
        '{ username: $username, sshPublicKey: $sshPublicKey }' \
        > utm/runtime.json

[doc("builds the bootstrap NixOS disk image that new UTM VMs start from")]
[group("UTM NixOS")]
[script]
utm-image: utm-runtime
    # macOS can't build aarch64-linux images, so a throwaway Lima VM running the
    # stock nixos-lima image builds it.
    builder="$(scripts/vm-instance-name.sh lima builder)"
    trap 'limactl delete --force "$builder" >/dev/null 2>&1 || true' EXIT
    just lima-start-instance "$builder" none
    mkdir -p utm/images

    # The image's store path only exists in the builder, so copy it out through
    # the worktree mount. "auto" sizes it to fit, so grow it for the guest.
    limactl shell --workdir {{ quote(lima_guest_config_dir) }} "$builder" -- sh -eu -c '
        image="$(nix build --option accept-flake-config true --no-link --print-out-paths \
            "path:.#packages.aarch64-linux.utm-bootstrap-image")"
        install -m 0644 "$image"/*.qcow2 utm/images/bootstrap.qcow2
        nix shell --inputs-from path:. nixpkgs#qemu-utils --command \
            qemu-img resize utm/images/bootstrap.qcow2 100G
    '

[private]
[script]
utm-exists instance:
    if {{ quote(utmctl) }} list | awk 'NR > 1 { print $3 }' | grep -Fxq {{ quote(instance) }}; then
        echo true
    else
        echo false
    fi

[doc("creates or starts the current worktree's NixOS UTM VM")]
[group("UTM NixOS")]
[arg("host", pattern=utm_nixos_hosts, help="the shortened NixOS host to run")]
[script]
utm-start host:
    host={{ quote(host) }}
    instance="$(scripts/vm-instance-name.sh utm "$host")"

    created=false
    if ! "$(just utm-exists "$instance")"; then
        just utm-image
        osascript utm/create-vm.applescript \
            "$instance" \
            "$(pwd -P)/utm/images/bootstrap.qcow2" \
            {{ quote(utm_memory) }} \
            {{ quote(utm_cpus) }} \
            {{ quote(utm_display_width) }} \
            {{ quote(utm_display_height) }} \
            > /dev/null
        # UTM copies the image into the VM bundle.
        rm utm/images/bootstrap.qcow2
        created=true
    fi

    if [ "$({{ quote(utmctl) }} status "$instance")" != "started" ]; then
        {{ quote(utmctl) }} start "$instance"
    fi

    if "$created"; then
        # Switch from the bootstrap image to the real host, then reboot so its
        # kernel and display manager take over.
        just utm-switch "$host"
        just utm-stop "$host"
        {{ quote(utmctl) }} start "$instance"
    fi

[private]
[script]
utm-ip host:
    instance="$(scripts/vm-instance-name.sh utm {{ quote(host) }})"
    # The guest agent reports addresses once the guest has booted.
    for _ in $(seq 120); do
        address="$({{ quote(utmctl) }} ip-address "$instance" 2>/dev/null \
            | grep -E '^[0-9]+(\.[0-9]+){3}$' | head -n 1 || true)"
        if [ -n "$address" ]; then
            printf '%s\n' "$address"
            exit
        fi
        sleep 2
    done
    echo "Timed out waiting for $instance's IP address." >&2
    exit 1

[private]
[script]
utm-sync host:
    host={{ quote(host) }}
    just utm-start "$host"
    address="$(just utm-ip "$host")"
    # The --delete keeps the copy identical to the worktree, which the
    # path: flake builds read in full.
    rsync -a --delete \
        --exclude /.git \
        --exclude /result \
        --exclude /utm/images \
        -e {{ quote("ssh " + utm_ssh_options) }} \
        ./ {{ quote(utm_username + "@") }}"$address":{{ quote(utm_guest_config_dir + "/") }}

[private]
[script]
utm-ssh host *command:
    host={{ quote(host) }}
    just utm-sync "$host"
    address="$(just utm-ip "$host")"
    exec ssh -t {{ utm_ssh_options }} \
        {{ quote(utm_username + "@") }}"$address" \
        {{ quote("cd " + utm_guest_config_dir + " && " + command) }}

[doc("syncs the worktree into its NixOS UTM VM and opens a shell there")]
[group("UTM NixOS")]
[arg("host", pattern=utm_nixos_hosts, help="the shortened NixOS host to run")]
utm-shell host:
    @just utm-ssh {{ quote(host) }} 'exec "$SHELL" -l'

[doc("syncs the worktree into its NixOS UTM VM and builds its system configuration")]
[group("UTM NixOS")]
[arg("host", pattern=utm_nixos_hosts, help="the shortened NixOS host configuration to build")]
utm-build-system host: utm-runtime
    just utm-ssh {{ quote(host) }} 'nix shell --inputs-from path:. nixpkgs-unstable#just nixpkgs#jq --command just build-system utm-nixos-{{ host }}'

[doc("syncs the worktree into its NixOS UTM VM and builds its home configuration")]
[group("UTM NixOS")]
[arg("host", pattern=utm_nixos_hosts, help="the shortened NixOS host configuration to build")]
utm-build-home host: utm-runtime
    just utm-ssh {{ quote(host) }} 'nix shell --inputs-from path:. nixpkgs-unstable#just nixpkgs#jq --command just build-home utm-nixos-{{ host }} {{ utm_username }}'

[doc("syncs the worktree into its NixOS UTM VM and applies it")]
[group("UTM NixOS")]
[arg("host", pattern=utm_nixos_hosts, help="the shortened NixOS host configuration to apply")]
utm-switch host: utm-runtime
    just utm-ssh {{ quote(host) }} 'nix shell --inputs-from path:. nixpkgs-unstable#just nixpkgs#jq --command just switch utm-nixos-{{ host }}'

[doc("stops the current worktree's NixOS UTM VM")]
[group("UTM NixOS")]
[arg("host", pattern=utm_nixos_hosts, help="the shortened NixOS host VM to stop")]
[script]
utm-stop host:
    instance="$(scripts/vm-instance-name.sh utm {{ quote(host) }})"

    if ! "$(just utm-exists "$instance")"; then
        echo "UTM VM '$instance' does not exist."
        exit
    fi

    just utm-stop-instance "$instance"

[private]
[script]
utm-stop-instance instance:
    instance={{ quote(instance) }}

    if [ "$({{ quote(utmctl) }} status "$instance")" != "started" ]; then
        exit
    fi

    # The default stop is a hard power off; ask the guest to shut down first.
    {{ quote(utmctl) }} stop --request "$instance"
    for _ in $(seq 60); do
        if [ "$({{ quote(utmctl) }} status "$instance")" = "stopped" ]; then
            exit
        fi
        sleep 2
    done
    echo "Timed out waiting for $instance to shut down; forcing it off." >&2
    {{ quote(utmctl) }} stop "$instance"

[doc("stops every running dotfiles NixOS UTM VM")]
[group("UTM NixOS")]
[script]
utm-stop-all:
    found=false
    for instance in $({{ quote(utmctl) }} list | awk 'NR > 1 && $2 == "started" { print $3 }'); do
        case "$instance" in
            dotfiles-utm-nixos-*)
                found=true
                just utm-stop-instance "$instance"
                ;;
        esac
    done

    if ! "$found"; then
        echo "No running dotfiles UTM VMs exist."
    fi

[doc("forcibly deletes the current worktree's NixOS UTM VM")]
[group("UTM NixOS")]
[arg("host", pattern=utm_nixos_hosts, help="the shortened NixOS host VM to delete")]
[script]
utm-delete host:
    host={{ quote(host) }}
    instance="$(scripts/vm-instance-name.sh utm "$host")"

    if ! "$(just utm-exists "$instance")"; then
        echo "UTM VM '$instance' does not exist."
        exit
    fi

    just utm-stop "$host"
    {{ quote(utmctl) }} delete "$instance"

[doc("forcibly deletes every dotfiles NixOS UTM VM")]
[group("UTM NixOS")]
[script]
utm-delete-all:
    found=false
    for instance in $({{ quote(utmctl) }} list | awk 'NR > 1 { print $3 }'); do
        case "$instance" in
            dotfiles-utm-nixos-*)
                found=true
                just utm-stop-instance "$instance"
                {{ quote(utmctl) }} delete "$instance"
                ;;
        esac
    done

    if ! "$found"; then
        echo "No dotfiles UTM VMs exist."
    fi
