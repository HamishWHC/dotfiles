{
  flake.features.gnome-keyring = {
    nixos = {
      services.gnome.gnome-keyring.enable = true;
    };
  };
}
