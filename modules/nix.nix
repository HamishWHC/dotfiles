{ inputs, ... }:

let
  shared = {
    nix.settings.substituters = [ "https://nix-community.cachix.org" ];
    nix.settings.trusted-public-keys = [
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

  flake.modules.nixos.nix = shared // {
    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [ "@admin" ];
    };
  };

  flake.modules.darwin.nix = shared // {
    imports = [ inputs.determinate.darwinModules.default ];
    nix.enable = false;
    determinateNix.enable = true;
  };
}
