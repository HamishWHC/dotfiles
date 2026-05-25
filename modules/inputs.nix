{inputs, ...}: {
  imports = [inputs.flake-file.flakeModules.default];
  
  flake-file = {
    description = "My personal dotfiles configuration.";

    inputs = {
      nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
      flake-parts.url = "github:hercules-ci/flake-parts";
      import-tree.url = "github:vic/import-tree";
      nix-homebrew.url = "github:zhaofengli/nix-homebrew";
      wrappers.url = "github:Lassulus/wrappers";
      flake-file.url = "github:vic/flake-file";
      determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";

      nix-darwin = {
        url = "github:nix-darwin/nix-darwin";
        inputs.nixpkgs.follows = "nixpkgs";
      };

      home-manager = {
        url = "github:nix-community/home-manager";
        inputs.nixpkgs.follows = "nixpkgs";
      };

      homebrew-core = {
        url = "github:homebrew/homebrew-core";
        flake = false;
      };

      homebrew-cask = {
        url = "github:homebrew/homebrew-cask";
        flake = false;
      };
    };
  };

  flake-file.outputs = "inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules)";
}