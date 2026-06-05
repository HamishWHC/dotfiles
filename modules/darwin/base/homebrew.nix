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
      host,
      lib,
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
          autoUpdate = false;
          upgrade = true;
          cleanup = "uninstall";
        };

        enableZshIntegration = true;

        taps = builtins.attrNames taps;
        masApps = {
          "Black Out" = 1319884285;
          "HEIC Converter" = 1294126402;
          "Shareful" = 1522267256;
          "UTC Time" = 1538245904;
          "Velja" = 1607635845;
        };
        casks = [
          "thaw"
          "aptakube"
          "burp-suite"
          "firefox"
        ]
        ++ (lib.lists.optional (host != "atlassian") "ungoogled-chromium")
        ++ [
          "grandperspective"
          "mac-mouse-fix"
          "mission-control-plus"
          "raycast"
          "rectangle"
          "shottr"
          "wireshark-app"
        ];
        brews = [
          "mas"
        ];
      };
    };
}
