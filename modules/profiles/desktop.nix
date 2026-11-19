{ self, ... }: {
  flake.profiles.desktop = [
    # Inherits from default profile (added automatically - this is redundant)
    self.profiles.default

    # Desktop Environment
    self.features.gnome-keyring
    self.features.noctalia

    # Desktop Apps
    self.features.ghostty
    self.features.browsers
    self.features.one-password
    self.features.discord
    self.features.vicinae

    # Enables local dotfiles development
    self.features.vscode

    # MacOS Configuration
    self.features.macos
    self.features.macos-necessities
  ];
}
