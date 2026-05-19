{ inputs, self, ... }:
{
  flake.lib.mkDarwinHost =
    {
      name,
      username,
      system ? "aarch64-darwin",
      homeDirectory ? /. + "/Users/${username}",
      manageUser ? false,
      homeStateVersion ? "25.11",
      modules ? [ ],
      homeModules ? [ ],
      # extraModules is the intended private/local extension point. A separate private flake
      # can pass work or auth-specific modules here without committing them to this public repo.
      extraModules ? [ ],
      extraSpecialArgs ? { },
      homeExtraSpecialArgs ? { },
    }:
    let
      userModules =
        if username == null then
          [ ]
        else
          [
            (
              { lib, pkgs, ... }:
              {
                # This identifies the primary existing user for nix-darwin modules such as Homebrew.
                # It does not create or mutate the account unless manageUser is explicitly enabled.
                system.primaryUser = lib.mkDefault username;

                home-manager.extraSpecialArgs = {
                  inherit self;
                } // homeExtraSpecialArgs;

                home-manager.users.${username} = {
                  imports = [ ../_home/default.nix ] ++ homeModules;

                  home = {
                    username = lib.mkDefault username;
                    homeDirectory = lib.mkForce homeDirectory;
                    stateVersion = homeStateVersion;
                  };
                };
              }
            )
            (
              { lib, pkgs, ... }:
              lib.mkIf manageUser {
                users.users.${username} = {
                  home = homeDirectory;
                  shell = pkgs.zsh;
                };
              }
            )
          ];
    in
    inputs.nix-darwin.lib.darwinSystem {
      inherit system;

      specialArgs = {
        inherit inputs self name username;
      } // extraSpecialArgs;

      modules =
        [
          inputs.home-manager.darwinModules.home-manager
          inputs.nix-homebrew.darwinModules.nix-homebrew
          self.darwinModules.default
        ]
        ++ userModules
        ++ modules
        ++ extraModules;
    };
}
