{ ... }:
{
  programs.zsh.enable = true;

  system = {
    stateVersion = 6;

    defaults = {
      NSGlobalDomain.AppleShowAllExtensions = true;
    };
  };
}
