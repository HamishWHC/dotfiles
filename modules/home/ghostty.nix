{ ... }:
{
  flake.homeModules.ghostty = { ... }: {
    xdg.configFile."ghostty/config".source = ../../home/.config/ghostty/config;
  };
}
