{
  flake.features.browsers = {
    darwin = {
      homebrew.casks = [ "ungoogled-chromium" ];
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
