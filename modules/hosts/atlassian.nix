{ inputs, self, ... }: {
  flake.darwinConfigurations.atlassian = self.lib.mkDarwinHost "atlassian" {
    system = "aarch64-darwin";
    username = "hcox";
    configDir = "/Users/hcox/Documents/Personal/dotfiles";
    usesCyberark = true;
    darwinModules = [
      {
        security.pam.services.sudo_local.enable = false;
      }
    ];
    homeManagerModules = [
      self.modules.homeManager.workstation
    ];
  };
}
