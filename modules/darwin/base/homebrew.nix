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

  flake.modules.darwin.homebrew =
    {
      username,
      ...
    }:
    let
      taps = {
        "homebrew/homebrew-core" = inputs.homebrew-core;
        "homebrew/homebrew-cask" = inputs.homebrew-cask;
      };
    in
    {
      imports = [ inputs.nix-homebrew.darwinModules.nix-homebrew ];

      nix-homebrew = {
        inherit taps;

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
          autoUpdate = true;
          upgrade = true;
          cleanup = "uninstall";
        };

        enableZshIntegration = true;

        taps = builtins.attrNames taps;
        casks = [
          "thaw"
        ];
        # brews = [
        #   # "bat"
        #   # "fzf"
        #   # "git"
        #   # "kubectl"
        #   # "kubectx"
        #   # "openssl"
        #   # "readline"
        #   # "sqlite3"
        #   # "tcl-tk"
        #   # "xh"
        #   # "xz"
        #   # "zlib"
        # ];
      };
    };
}
