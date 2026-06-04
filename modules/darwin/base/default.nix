{
  inputs,
  self,
  ...
}:
{
  flake-file.inputs = {
    gum.url = "github:charmbracelet/gum";
  };

  flake.modules.darwin.base =
    {
      pkgs,
      lib,
      username,
      ...
    }:
    {
      imports = [
        self.modules.darwin.nix
        self.modules.darwin.homebrew
        self.modules.darwin.home-manager
      ];

      system.primaryUser = username;
      users.users.${username}.home = "/Users/${username}";
      system.stateVersion = 7;

      # Intentionally do not set networking.hostName, networking.computerName, or
      # networking.localHostName. The flake host names are friendly names only.

      environment.systemPackages = with pkgs; [
        gum
      ];

      programs.zsh.enableGlobalCompInit = false;
    };
}
