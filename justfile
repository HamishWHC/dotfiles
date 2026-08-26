set default-list := true

[doc("check that the nix code is syntactically correct and is not completely insane")]
check:
    nix flake check

[doc("updates flake.lock with the latest matching versions")]
update:
    nix flake update

[doc("updates flake.nix with input changes")]
write-flake:
    nix run ".#write-flake"

[doc("builds the darwin system configuration")]
build-system host:
    rm -rf result
    nix build ".#darwinConfigurations.{{host}}.system"

[doc("builds the home activation package")]
build-home host username:
    rm -rf result
    nix build ".#darwinConfigurations.{{host}}.config.home-manager.users.{{username}}.home.activationPackage"

[doc("applies the given configuration to the system")]
switch host:
    sudo nix run "nix-darwin#darwin-rebuild" -- switch --flake ".#{{host}}"

[doc("generate new device key")]
[group("secrets")]
new-key:
    # Probably best to just run this script directly, since a new device likely doesn't have `just` installed!
    scripts/new-key.sh

[doc("syncs secrets with changed device keys")]
[group("secrets")]
update-keys:
    sops updatekeys secrets/*

[doc("rotates data keys - good to do regularly")]
[group("secrets")]
rotate-data-keys:
    sops rotate -i secrets/*