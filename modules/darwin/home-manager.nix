{inputs, ...}: {
  flake.modules.darwin.home-manager = {
    self,
    username,
    ...
  }: {
    imports = [inputs.home-manager.darwinModules.home-manager];

    users.users.${username}.home = "/Users/${username}";

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";
      extraSpecialArgs = {
        inherit inputs self username;
      };
      users.${username} = {
        imports = [
          self.modules.homeManager.default
        ];

        home = {
          inherit username;
          homeDirectory = "/Users/${username}";
          stateVersion = "25.11";
        };
      };
    };
  };
}
