{
  flake.features.sway = {
    nixos =
      {
        pkgs,
        config,
        lib,
        ...
      }:
      {
        environment.systemPackages = with pkgs; [
          wl-clipboard # Copy/Paste functionality.
          mako # Notification utility.
        ];

        security.pam.services = lib.mkIf (config.services.gnome.gnome-keyring.enable) {
          swaylock.enableGnomeKeyring = true;
        };

        # Enable Sway.
        programs.sway = {
          enable = true;
          wrapperFeatures.gtk = true;
        };
      };
  };
}
