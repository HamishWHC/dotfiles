{ inputs, ... }:
let
  sharedSettings = {
    extra-substituters = [ "https://nix-community.cachix.org" ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
in
{
  flake-file.inputs = {
    determinate = {
      url = "https://flakehub.com/f/DeterminateSystems/determinate/3";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
  };

  flake.features.nix = {
    nixos = {
      nix.settings = sharedSettings // {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        trusted-users = [ "@admin" ];
      };
    };

    darwin =
      {
        config,
        lib,
        pkgs,
        username,
        ...
      }:
      {
        imports = [ inputs.determinate.darwinModules.default ];

        nix.enable = false;
        determinateNix = {
          enable = true;
          customSettings = sharedSettings // {
            trusted-users = [ "@admin" ];
          };
        };

        sops.templates."github-access-token.conf" = {
          owner = username;
          mode = "0400";
          content = "access-tokens = github.com=${config.sops.placeholder.github-token}";
        };

        # Override the contents of the nix custom config with the GitHub token attached.
        environment.etc."nix/nix.custom.conf".source = lib.mkForce (
          pkgs.writeText "nix.custom.conf" ''
            !include ${config.sops.templates."github-access-token.conf".path}

            ${config.environment.etc."nix/nix.custom.conf".text}
          ''
        );
      };
  };
}
