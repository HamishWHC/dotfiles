{ inputs, self, ... }:
{
  flake.modules.darwin.home-manager =
    {
      username,
      homeManagerImports,
      ...
    }:
    {
      imports = [ inputs.home-manager.darwinModules.home-manager ];

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "backup";
        extraSpecialArgs = {
          inherit username;
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
        };
      };
    };
}
