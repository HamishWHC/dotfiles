{
  flake.features.aptakube = {
    homeManager =
      { pkgs, lib, ... }:
      {
        home.packages = lib.mkIf (pkgs.stdenv.isLinux) [
          pkgs.unstable.aptakube
        ];
      };

    darwin = { lib, pkgs, ... }: {
      homebrew.casks = lib.mkIf (pkgs.stdenv.isDarwin) [ "aptakube" ];
    };
  };
}
