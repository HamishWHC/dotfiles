{
  self,
  inputs,
  lib,
  ...
}:
{
  flake-file.inputs.nixos-lima = {
    url = "github:nixos-lima/nixos-lima/master";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.lib.mkNixosHost =
    name:
    {
      system,
      username,
      configDir,
      features ? [ ],
    }:
    let
      modules = builtins.zipAttrsWith (class: modules: modules) (
        lib.flatten ([ self.profiles.default ] ++ features)
      );
    in
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;

      pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [
          self.overlays.custom
          self.overlays.unstable
          inputs.nix-vscode-extensions.overlays.default
        ];
        config.allowUnfree = true;
      };

      specialArgs = {
        inherit
          configDir
          username
          system
          ;
        host = name;
      };

      modules = [
        inputs.home-manager.nixosModules.home-manager
        {
          imports = modules.nixos;
          home-manager.users.${username}.imports = modules.homeManager;
        }
      ];
    };
}
