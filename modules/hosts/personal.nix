{ inputs, self, ... }:
{
  flake.darwinConfigurations.personal = inputs.nix-darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    specialArgs = {
      host = "personal";
      configDir = "/Users/hamishwhc/Documents/Projects/dotfiles";
      username = "hamishwhc";
      homeManagerImports = [
        self.modules.homeManager.workstation
      ];
    };
    modules = [
      self.modules.darwin.base
      {
        security.pam.services.sudo_local.enable = true;
        security.pam.services.sudo_local.reattach = true;
        security.pam.services.sudo_local.touchIdAuth = true;
      }
    ];
  };
}
