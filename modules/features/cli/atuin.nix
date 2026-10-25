{
  flake.features.atuin.homeManager = {
    programs.atuin = {
      enable = true;
      # Replace the existing unmanaged config; its only non-default settings are declared below.
      forceOverwriteSettings = true;
      settings = {
        enter_accept = true;
        sync.records = true;
      };
    };
  };
}
