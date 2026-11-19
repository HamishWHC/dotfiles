{
  flake.features.ghostty.homeManager =
    { pkgs, lib, ... }:
    {
      home.packages =
        lib.optional (pkgs.stdenv.isDarwin) pkgs.ghostty-bin
        ++ lib.optional (pkgs.stdenv.isLinux) pkgs.ghostty;
      # Ghostty converts points at 72 DPI on macOS and 96 DPI elsewhere, so
      # 12pt on Linux renders at the same logical size as 16pt on macOS.
      xdg.configFile."ghostty/config".text = ''
        font-size = ${if pkgs.stdenv.isDarwin then "16" else "12"}
      ''
      + builtins.readFile ./config;

      home.file = lib.mkIf (pkgs.stdenv.isDarwin) {
        "Library/Services/Open Terminal Here.workflow".source = ./${"Open Terminal Here.workflow"};
      };
    };
}
