{inputs, self, ...}: {
  flake.darwinConfigurations.personal = inputs.nix-darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    specialArgs = {
      inherit inputs self;
      username = "hamishwhc";
    };
    modules = [
      self.modules.darwin.core
      self.modules.darwin.homebrew
      self.modules.darwin.home-manager
    ];
  };
}
