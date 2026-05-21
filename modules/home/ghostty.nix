{...}: {
  flake.modules.homeManager.ghostty = {...}: {
    xdg.configFile."ghostty/config".source = ../../home/.config/ghostty/config;
  };
}
