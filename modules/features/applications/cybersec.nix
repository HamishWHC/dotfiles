{
  flake.features.cybersec = {
    darwin = {
      # Burpsuite via Nixpkgs is broken on Darwin:
      # https://github.com/NixOS/nixpkgs/issues/544950
      homebrew.casks = [ "burp-suite" ];
    };

    homeManager =
      { pkgs, ... }:
      {
        home.packages =
          with pkgs;
          [
            ghidra
            wireshark
          ]
          ++ lib.optional (pkgs.stdenv.isLinux) pkgs.unstable.burpsuite;
      };
  };
}
