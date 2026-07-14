{ self, ... }:
{
  flake.darwinConfigurations.personal = self.lib.mkDarwinHost "personal" {
    system = "aarch64-darwin";
    username = "hamishwhc";
    configDir = "/Users/hamishwhc/Documents/Projects/dotfiles";
    features = [
      self.profiles.workstation
      {
        darwin = {
          security.pam.services.sudo_local.enable = true;
          security.pam.services.sudo_local.reattach = true;
          security.pam.services.sudo_local.touchIdAuth = true;
        };
      }
    ];
  };
}
