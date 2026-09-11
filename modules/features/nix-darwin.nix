{
  flake.features.nix-darwin = {
    darwin =
      {
        username,
        ...
      }:
      {
        system.primaryUser = username;
        users.users.${username}.home = "/Users/${username}";
        system.stateVersion = 7;

        # Workaround for:
        # https://github.com/nix-darwin/nix-darwin/issues/1817
        documentation.enable = false;
        system.tools.darwin-uninstaller.enable = false;

        # Intentionally do not set networking.hostName, networking.computerName, or
        # networking.localHostName. The flake host names are friendly names only.

        programs.zsh.enableGlobalCompInit = false;
      };
  };
}
