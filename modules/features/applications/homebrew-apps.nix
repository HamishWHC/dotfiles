{
  flake.features.homebrew-apps.darwin =
    {
      host,
      lib,
      ...
    }:
    {
      nix-homebrew.taps = {
        # Additional taps can be added here, e.g.:
        # "homebrew/cask-fonts" = inputs.homebrew-cask-fonts;
      };

      homebrew = {
        masApps = {
          "Black Out" = 1319884285;
          "HEIC Converter" = 1294126402;
          "Shareful" = 1522267256;
          "UTC Time" = 1538245904;
          "Velja" = 1607635845;
          "The Unarchiver" = 425424353;
          "Presentify" = 1507246666;
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
          "hex-fiend"
        ];
      };
    };
}
