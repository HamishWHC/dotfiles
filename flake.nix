# DO-NOT-EDIT. This file was auto-generated using github:vic/flake-file.
# Use `nix run .#write-flake` to regenerate it.
{
  description = "My personal dotfiles configuration.";

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);

  inputs = {
    atuin.url = "github:atuinsh/atuin";
    determinate = {
      url = "https://flakehub.com/f/DeterminateSystems/determinate/3";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
    direnv-instant.url = "github:Mic92/direnv-instant";
    flake-file.url = "github:vic/flake-file";
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    homebrew-acli = {
      url = "github:atlassian/homebrew-acli";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    import-tree.url = "github:vic/import-tree";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    wrappers.url = "github:Lassulus/wrappers";
  };
}
