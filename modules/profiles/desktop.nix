{ self, ... }: {
  flake.profiles.desktop = [
    # Inherits from default profile (added automatically - this is redundant)
    self.profiles.default

    # Desktop Environment
    self.features.gnome-keyring
    self.features.tuigreet
    self.features.sway

    # Desktop Apps
    self.features.ghostty
    self.features.browsers

    # MacOS Configuration
    self.features.macos-necessities
  ];
}
