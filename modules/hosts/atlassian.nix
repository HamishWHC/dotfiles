{ inputs, self, ... }:
{
  flake.darwinConfigurations.atlassian = self.lib.mkDarwinHost "atlassian" {
    system = "aarch64-darwin";
    username = "hcox";
    configDir = "/Users/hcox/Documents/Personal/dotfiles";
    usesCyberark = true;
    darwinModules = [
      {
        security.pam.services.sudo_local.enable = false;
        # security.pam.services.sudo_local.enable = true;
        # security.pam.services.sudo_local.reattach = true;
        # security.pam.services.sudo_local.touchIdAuth = true;
      }
    ];
    homeManagerModules = [
      self.modules.homeManager.workstation
    ];
  };
}
