{
  flake.modules.homeManager.ghostty = {pkgs, ...}: {
    home.packages = [ pkgs.ghostty-bin ];
    xdg.configFile."ghostty/config".source = ./config;
  };
}
