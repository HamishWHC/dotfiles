{ self, ... }: {
  flake.features.browsers = {
    darwin = {
      imports = [ self.features.velja.darwin ];
      homebrew = {
        casks = [ "ungoogled-chromium" ];
      };
    };
    homeManager = { lib, pkgs, ... }: {
      imports = [
        self.features.firefox.homeManager
        ./selector/_home.nix
      ];

      # Stable, because Hydra builds unstable's aarch64-linux Chromium late and
      # compiling it locally takes hours.
      home.packages = lib.mkIf (pkgs.stdenv.isLinux) [ pkgs.ungoogled-chromium ];
    };
  };
}
