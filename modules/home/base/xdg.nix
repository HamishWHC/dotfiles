{
  flake.modules.homeManager.xdg = {
    home.preferXdgDirectories = true;

    xdg.enable = true;
    xdg.localBinInPath = true;
  };
}
