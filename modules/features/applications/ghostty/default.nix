{
  flake.features.ghostty.homeManager =
    { pkgs, lib, ... }:
    {
      home.packages =
        lib.optional (pkgs.stdenv.isDarwin) pkgs.ghostty-bin
        ++ lib.optional (pkgs.stdenv.isLinux) pkgs.ghostty;
      xdg.configFile."ghostty/config".source = ./config;

      home.file = lib.mkIf (pkgs.stdenv.isDarwin) {
        "Library/Services/Open Terminal Here.workflow".source = ./${"Open Terminal Here.workflow"};
      };
    };
}
