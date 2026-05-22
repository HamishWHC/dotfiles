{ self, inputs, ... }:
let shared = {
  nixpkgs.overlays = [ self.overlays.custom ];
  nixpkgs.config.allowUnfree = true;
}; in {
  flake-file.inputs = {
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";
  };

  flake.modules.nixos.nix-settings = {pkgs, lib, ...}: shared // {
    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [ "@admin" ];
    };
  };

  flake.modules.darwin.nix = {pkgs, lib, ...}: shared // {
    imports = [ inputs.determinate.darwinModules.default ];
    nix.enable = false;
    determinateNix.enable = true;
  };
}
