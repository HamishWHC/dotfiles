{ inputs, self, ... }:
let
  darwinModules = rec {
    nix = (import ../darwin/nix.nix { }).flake.darwinModules.nix;
    home-manager = (import ../darwin/home-manager.nix { }).flake.darwinModules.home-manager;
    homebrew = (import ../darwin/homebrew.nix { }).flake.darwinModules.homebrew;
    system = (import ../darwin/system.nix { }).flake.darwinModules.system;
    default = {
      imports = [
        nix
        home-manager
        homebrew
        system
      ];
    };
  };

  homeModules = rec {
    packages = (import ../home/packages.nix { }).flake.homeModules.packages;
    zsh = (import ../home/zsh.nix { }).flake.homeModules.zsh;
    git = (import ../home/git.nix { }).flake.homeModules.git;
    ssh = (import ../home/ssh.nix { }).flake.homeModules.ssh;
    ghostty = (import ../home/ghostty.nix { }).flake.homeModules.ghostty;
    default = {
      imports = [
        packages
        zsh
        git
        ssh
        ghostty
      ];
    };
  };

  mkHost =
    {
      name,
      username,
      homeDirectory ? /. + "/Users/${username}",
      homeStateVersion ? "25.11",
      system ? "aarch64-darwin",
    }:
    inputs.nix-darwin.lib.darwinSystem {
      inherit system;

      specialArgs = {
        inherit inputs self name username;
      };

      modules = [
        inputs.home-manager.darwinModules.home-manager
        inputs.nix-homebrew.darwinModules.nix-homebrew
        darwinModules.default
        (
          { lib, ... }:
          {
            # Identifies the existing primary user for nix-darwin/Homebrew without creating or mutating it.
            system.primaryUser = lib.mkDefault username;

            home-manager.extraSpecialArgs = {
              inherit self;
            };

            home-manager.users.${username} = {
              imports = [ homeModules.default ];

              home = {
                username = lib.mkDefault username;
                homeDirectory = lib.mkForce homeDirectory;
                stateVersion = homeStateVersion;
              };
            };
          }
        )
      ];
    };
in
{
  flake.darwinConfigurations = {
    atlassian = mkHost {
      name = "atlassian";
      username = "hcox";
    };

    personal = mkHost {
      name = "personal";
      username = "hamishwhc";
    };
  };
}
