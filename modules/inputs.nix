{ inputs, ... }:
{
  imports = [ inputs.flake-file.flakeModules.default ];

  flake-file = {
    description = "My personal dotfiles configuration.";

    inputs = {
      nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
      nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
      nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
      flake-parts.url = "github:hercules-ci/flake-parts";
      import-tree.url = "github:vic/import-tree";
      wrappers.url = "github:Lassulus/wrappers";
      flake-file.url = "github:vic/flake-file";
      home-manager = {
        url = "github:nix-community/home-manager/release-26.05";
        inputs.nixpkgs.follows = "nixpkgs-unstable";
      };
      nix-darwin = {
        url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
        inputs.nixpkgs.follows = "nixpkgs-unstable";
      };
    };

    outputs = "inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules)";
  };
}
