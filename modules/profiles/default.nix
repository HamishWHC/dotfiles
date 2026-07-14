{ self, ... }: {
  flake.profiles.default = [
    # Shared core features
    self.features.nix
    self.features.home-manager

    # Darwin core features
    self.features.nix-darwin
    self.features.homebrew

    # Always-on features
    self.features.mac-mouse-fix
    self.features.automator
    self.features.terminal
  ];
}
