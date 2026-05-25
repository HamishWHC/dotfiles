{ inputs, self, ... }:
{
  flake.darwinConfigurations.atlassian = inputs.nix-darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    specialArgs = {
      host = "atlassian";
      configDir = "/Users/hcox/Documents/Personal/dotfiles";
      username = "hcox";
      homeManagerImports = [
        self.modules.homeManager.workstation
      ];
    };
    modules = [
      self.modules.darwin.base
      {
        security.pam.services.sudo_local.enable = false;
      }
    ];
  };
}
