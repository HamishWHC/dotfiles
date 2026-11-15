{
  flake.features.steam.nixos = {
    # Also enables the 32-bit graphics drivers that Steam and Proton need.
    programs.steam.enable = true;
  };
}
