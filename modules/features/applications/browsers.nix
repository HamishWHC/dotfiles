{
  flake.features.browsers = {
    darwin = {
      homebrew = {
        masApps = {
          "Velja" = 1607635845;
        };
        casks = [ "ungoogled-chromium" ];
      };
    };
    homeManager =
      { pkgs, ... }:
      {
        home.packages =
          with pkgs;
          [
            unstable.firefox-bin
          ]
          ++ lib.optional (pkgs.stdenv.isLinux) pkgs.unstable.ungoogled-chromium;
      };
  };
}
