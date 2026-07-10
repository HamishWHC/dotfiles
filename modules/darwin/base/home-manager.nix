{ self, ... }:
{
  flake.modules.darwin.home-manager =
    {
      username,
      homeManagerModules,
      system,
      configDir,
      host,
      ...
    }:
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "backup";
        extraSpecialArgs = {
          inherit
            username
            configDir
            host
            system
            ;
        };

        users.${username} = {
          imports = [
            self.modules.homeManager.base
            self.modules.homeManager.darwin
          ]
          ++ homeManagerModules;

          home = {
            inherit username;
            stateVersion = "26.05";
            homeDirectory = "/Users/${username}";
          };

          # Enable the home-manager binary.
          programs.home-manager.enable = true;
          # Disable nix in home-manager since Determinate is incompatible: https://github.com/DeterminateSystems/determinate#home-manager
          nix.package = null;
        };
      };
    };
}
