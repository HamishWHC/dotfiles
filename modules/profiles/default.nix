{ self, ... }: {
  flake.profiles.default = [
    # Shared core features
    self.features.nix
    self.features.secrets
    self.features.home-manager
    self.features.dotfiles

    # NixOS core features
    self.features.nixos

    # Darwin core features
    self.features.nix-darwin
    self.features.homebrew

    # Packages and terminal features
    self.features.zsh
    self.features.atuin
    self.features.git
    self.features.hushlogin
    self.features.xdg
    self.features.ssh-client
  ];
}
