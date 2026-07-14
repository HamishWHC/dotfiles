{
  flake.features.ghostty.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.ghostty-bin ];
      xdg.configFile."ghostty/config".source = ./config;
    };
}
