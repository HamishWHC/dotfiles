{
  self,
  inputs,
  lib,
  ...
}:
{
  flake.lib.mkDarwinHost =
    name:
    {
      system,
      username,
      configDir,
      features ? [ ],
      usesCyberark ? false,
    }:
    let
      modules = builtins.zipAttrsWith (class: modules: modules) (
        lib.flatten ([ self.profiles.default ] ++ features)
      );

      pkgs = inputs.nixpkgs.legacyPackages.${system};

      # Necessary for devices using Cyberark EPM, which modifies the PATH when running commands with elevated privileges.
      # This patch ensures that the PATH is preserved when running the home-manager activation script.
      patchedHomeManager = pkgs.applyPatches {
        name = "home-manager-darwin-preserve-path";
        src = inputs.home-manager;
        patches = [ ./home-manager-darwin-preserve-path.patch ];
      };

      homeManager =
        if usesCyberark then
          "${patchedHomeManager}/nix-darwin"
        else
          inputs.home-manager.darwinModules.home-manager;
    in
    inputs.nix-darwin.lib.darwinSystem {
      inherit system;

      pkgs = import inputs.nixpkgs-darwin {
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
        homeManager
        {
          imports = modules.darwin;
          home-manager.users.${username}.imports = modules.homeManager;
        }
      ];
    };
}
