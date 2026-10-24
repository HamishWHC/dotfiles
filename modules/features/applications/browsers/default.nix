{ self, ... }: {
  flake.features.browsers = {
    darwin = {
      imports = [ self.features.velja.darwin ];
      homebrew = {
        casks = [ "ungoogled-chromium" ];
      };
    };
    homeManager = { lib, pkgs, ... }: {
      imports = [ self.features.firefox.homeManager ];

      home.packages = lib.mkIf (pkgs.stdenv.isLinux) pkgs.unstable.ungoogled-chromium;
    };
  };
}
