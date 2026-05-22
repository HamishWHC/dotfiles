{ inputs, self, ... }:
{
  flake.darwinConfigurations.personal = inputs.nix-darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    specialArgs = {
      username = "hamishwhc";
      homeManagerImports = [
        self.modules.homeManager.workstation
      ];
    };
    modules = [
      self.modules.darwin.base
    ];
  };
}
