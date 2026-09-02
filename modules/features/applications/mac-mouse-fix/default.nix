{
  flake.features.mac-mouse-fix = {
    homeManager =
      { lib, pkgs, ... }:
      lib.mkIf (pkgs.stdenv.isDarwin) {
        home.file."Library/Application Support/com.nuebling.mac-mouse-fix/config.plist" = {
          source = ./mac-mouse-fix.plist;
          force = true;
        };
      };
  };
}
