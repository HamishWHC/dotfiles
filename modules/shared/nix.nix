{ self, inputs, ... }:
let
  shared = {
    nixpkgs.overlays = [ self.overlays.custom ];
    nixpkgs.config.allowUnfree = true;
  };
in
{
  flake-file.inputs = {
    determinate = {
      url = "https://flakehub.com/f/DeterminateSystems/determinate/3";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.nixos.nix-settings = shared // {
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
