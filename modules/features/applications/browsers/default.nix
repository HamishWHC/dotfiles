{ self, ... }: {
  flake.features.browsers = {
    darwin = {
      homebrew = {
        masApps = {
          "Velja" = 1607635845;
        };
        casks = [ "ungoogled-chromium" ];
      };
    };
    homeManager = { lib, pkgs, ... }: {
      imports = [ self.features.firefox.homeManager ];

      home.packages = lib.mkIf (pkgs.stdenv.isLinux) pkgs.unstable.ungoogled-chromium;
    };
  };
}
