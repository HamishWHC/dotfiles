# Dotfiles

My personal dotfiles for my macOS devices as a nix flake configured with nix-darwin and home-manager. It uses the dendritic flake pattern for organising modules.

## Secrets

Secrets are encrypted with [sops-nix](https://github.com/Mic92/sops-nix) and age.

### Adding a new device
To onboard a new device, run `scripts/new-key.sh` (or `just new-key`, but a new device hasn't had `just` installed yet!).

Communicate the public key you get to an already onboarded device and add it to `.sops.yaml`'s `definitions.keys` list.
Then run `just update-keys` and push the changes to the `secrets/` directory.
These changes can then be pulled on the new device, which can then build and switch as normal.
