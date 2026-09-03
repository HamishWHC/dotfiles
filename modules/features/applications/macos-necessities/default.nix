{ self, ... }: {
  flake.features.macos-necessities = {
    homeManager = { lib, pkgs, ... }: {
      imports = [ self.features.mac-mouse-fix.homeManager ];

      home.packages = lib.mkIf (pkgs.stdenv.isDarwin) (
        with pkgs;
        [
          unstable.thaw
          unstable.rectangle
          unstable.shottr
          unstable.hexfiend
        ]
      );
    };

    darwin = {
      imports = [ self.features.mac-mouse-fix.darwin ];

      homebrew.casks = [
        "grandperspective"
        "mission-control-plus"
        "raycast"
      ];

      homebrew.masApps = {
        "Black Out" = 1319884285;
        "HEIC Converter" = 1294126402;
        "Shareful" = 1522267256;
        "UTC Time" = 1538245904;
        "The Unarchiver" = 425424353;
        "Presentify" = 1507246666;
      };
    };
  };
}
