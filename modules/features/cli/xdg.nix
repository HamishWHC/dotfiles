{
  flake.features.xdg.homeManager = {
    home.preferXdgDirectories = true;

    xdg.enable = true;
    xdg.localBinInPath = true;
  };
}
