{ self, ... }: {
  flake.profiles.gaming = [
    # Inherits from desktop profile
    self.profiles.desktop

    # Games
    self.features.steam
  ];
}
