{ inputs, self, ... }:
{
  flake.darwinConfigurations.atlassian = inputs.nix-darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    specialArgs = {
      username = "hcox";
      homeManagerImports = [
        self.modules.homeManager.workstation
      ];
    };
    modules = [
      self.modules.darwin.base
    ];
  };
}
