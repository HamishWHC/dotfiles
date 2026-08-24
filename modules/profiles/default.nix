{ self, ... }: {
  flake.profiles.default = [
    # Shared core features
    self.features.nix
    self.features.home-manager

    # Darwin core features
    self.features.nix-darwin
    self.features.homebrew
    self.features.mac-mouse-fix
    self.features.automator

    # Packages and terminal features
    self.features.zsh
    self.features.atuin
    self.features.git
    self.features.hushlogin
    self.features.xdg
    self.features.ssh-client
    self.features.misc-base-packages
    self.features.kube
  ];
}
