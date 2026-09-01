{ self, ... }: {
  flake.profiles.desktop = [
    # Inherits from default profile (added automatically - this is redundant)
    self.profiles.default

    # Desktop Apps
    self.features.ghostty
    self.features.homebrew-apps

    # MacOS Configuration
    self.features.mac-mouse-fix
  ];
}
