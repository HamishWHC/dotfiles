{ inputs, self, ... }:
{
  flake.darwinConfigurations.personal = self.lib.mkDarwinHost "personal" {
    system = "aarch64-darwin";
    username = "hamishwhc";
    configDir = "/Users/hamishwhc/Documents/Projects/dotfiles";
    darwinModules = [
      {
        security.pam.services.sudo_local.enable = true;
        security.pam.services.sudo_local.reattach = true;
        security.pam.services.sudo_local.touchIdAuth = true;
      }
    ];
    homeManagerModules = [
      self.modules.homeManager.workstation
    ];
  };
}
