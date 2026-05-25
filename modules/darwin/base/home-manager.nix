{ inputs, self, ... }:
{
  flake.modules.darwin.home-manager =
    {
      username,
      homeManagerImports,
      lib,
      configDir,
      host,
      ...
    }:
    {
      imports = [ inputs.home-manager.darwinModules.home-manager ];

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "backup";
        extraSpecialArgs = {
          inherit username configDir host;
        };

        users.${username} = {
          imports = [
            self.modules.homeManager.base
          ] ++ homeManagerImports;

          home =  {
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
