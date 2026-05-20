{ ... }:
let
  darwinModules = rec {
    nix = (import ./nix.nix { }).flake.darwinModules.nix;
    home-manager = (import ./home-manager.nix { }).flake.darwinModules.home-manager;
    homebrew = (import ./homebrew.nix { }).flake.darwinModules.homebrew;
    system = (import ./system.nix { }).flake.darwinModules.system;
  };
in
{
  flake.darwinModules.default = {
    imports = [
      darwinModules.nix
      darwinModules.home-manager
      darwinModules.homebrew
      darwinModules.system
    ];
  };
}
