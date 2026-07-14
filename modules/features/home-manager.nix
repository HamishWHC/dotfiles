{
  flake.features.home-manager = {
    homeManager = { username, ... }: {
      home = {
        inherit username;
        stateVersion = "26.05";
      };

      # Enable the home-manager binary.
      programs.home-manager.enable = true;
    };

    darwin =
      {
        username,
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
            home.homeDirectory = "/Users/${username}";

            # Disable nix in home-manager since Determinate is incompatible: https://github.com/DeterminateSystems/determinate#home-manager
            nix.package = null;
          };
        };
      };
  };
}
