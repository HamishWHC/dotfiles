{ self, inputs, ... }:
{
  flake.lib.mkDarwinHost =
    name:
    {
      system,
      username,
      configDir,
      darwinModules ? [ ],
      usesCyberark ? false,
      homeManagerModules ? null,
    }:
    let
      pkgs = inputs.nixpkgs.legacyPackages.${system};

      # Necessary for devices using Cyberark EPM, which modifies the PATH when running commands with elevated privileges.
      # This patch ensures that the PATH is preserved when running the home-manager activation script.
      patchedHomeManager = pkgs.applyPatches {
        name = "home-manager-darwin-preserve-path";
        src = inputs.home-manager;
        patches = [ ./home-manager-darwin-preserve-path.patch ];
      };

      realDarwinModules = [
        self.modules.darwin.base
      ]
      ++ (
        if usesCyberark then
          [ "${patchedHomeManager}/nix-darwin" ]
        else
          [ inputs.home-manager.darwinModules.home-manager ]
      )
      ++ darwinModules;
    in
    inputs.nix-darwin.lib.darwinSystem {
      inherit system;
      specialArgs = {
        inherit configDir username homeManagerModules;
        host = name;
      };
      modules = realDarwinModules;
    };
}
