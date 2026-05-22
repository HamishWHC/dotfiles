{ self, inputs, ... }:
{
  flake-file.inputs = {
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";
  };

  flake.modules.nixos.nix-settings = {pkgs, ...}: {
    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [ "@admin" ];
    };

    nixpkgs.overlays = [ self.overlays.custom ];
  };

  flake.modules.darwin.nix = {pkgs, ...}: {
    imports = [ inputs.determinate.darwinModules.default ];
    nix.enable = false;
    determinateNix.enable = true;

    nixpkgs.overlays = [ self.overlays.custom ];
  };
}
