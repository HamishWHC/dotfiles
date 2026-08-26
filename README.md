# Dotfiles

My personal dotfiles for my macOS devices as a nix flake configured with nix-darwin and home-manager. It uses the dendritic flake pattern for organising modules.

## Secrets

Secrets are encrypted with [sops-nix](https://github.com/Mic92/sops-nix) and age.

### Adding a new device
To onboard a new device, run `scripts/new-key.sh` (or `just new-key`, but a new device hasn't had `just` installed yet!).

Communicate the public key you get to an already onboarded device and add it to `.sops.yaml`'s `definitions.keys` list.
Then run `just update-keys` and push the changes to the `secrets/` directory.
These changes can then be pulled on the new device, which can then build and switch as normal.

I have added support for keys stored in a Mac's Secure Enclave but truth be told its not worth the hassle of needing to Touch ID during a switch since the secrets will end up somewhere on the device anyway.

Also perhaps shouldn't be pushing secrets into a public repo, encryption or not, but 1. fuck it we ball and 2. wow you broke AES-256 and decided to hack my Github token, well done.