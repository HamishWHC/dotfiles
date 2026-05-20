{ ... }:
let
  homeModules = rec {
    packages = (import ./packages.nix { }).flake.homeModules.packages;
    zsh = (import ./zsh.nix { }).flake.homeModules.zsh;
    git = (import ./git.nix { }).flake.homeModules.git;
    ssh = (import ./ssh.nix { }).flake.homeModules.ssh;
    ghostty = (import ./ghostty.nix { }).flake.homeModules.ghostty;
  };
in
{
  flake.homeModules.default = {
    imports = [
      homeModules.packages
      homeModules.zsh
      homeModules.git
      homeModules.ssh
      homeModules.ghostty
    ];
  };
}
