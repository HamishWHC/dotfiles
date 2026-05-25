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
    {
      imports = [ inputs.nix-homebrew.darwinModules.nix-homebrew ];

      nix-homebrew = {
        enable = true;
        autoMigrate = true;
        mutableTaps = true;
        
        user = username;
        taps = {
          "homebrew/homebrew-core" = inputs.homebrew-core;
          "homebrew/homebrew-cask" = inputs.homebrew-cask;
        };
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
