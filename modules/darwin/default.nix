{ self, ... }:
{
  flake.darwinModules.default = {
    imports = [
      ../_darwin/home-manager.nix
      ../_darwin/homebrew.nix
      ../_darwin/nix.nix
      ../_darwin/system.nix
    ];
  };
}
