{ inputs, ... }:
{
  flake-file.inputs = {
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };

    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
  };

  flake.features.homebrew.darwin =
    {
      username,
      lib,
      config,
      ...
    }:
    {
      imports = [ inputs.nix-homebrew.darwinModules.nix-homebrew ];

      nix-homebrew = {
        taps = {
          "homebrew/homebrew-core" = inputs.homebrew-core;
          "homebrew/homebrew-cask" = inputs.homebrew-cask;
        };

        enable = true;
        autoMigrate = true;
        mutableTaps = true;

        user = username;
      };

      homebrew = {
        enable = true;

        global.brewfile = true;
        global.autoUpdate = false;
        onActivation = {
          autoUpdate = false;
          upgrade = true;
          cleanup = "uninstall";
        };

        enableZshIntegration = true;

        taps = lib.attrNames config.nix-homebrew.taps;
        brews = [
          "mas"
        ];
      };
    };
}
