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
            (unstable.firefox-bin.override {
              # Bundle policies.json with Firefox so Nix manages browser updates.
              extraPolicies.DisableAppUpdate = true;
            })
          ]
          ++ lib.optional (pkgs.stdenv.isLinux) pkgs.unstable.ungoogled-chromium;
      };
  };
}
