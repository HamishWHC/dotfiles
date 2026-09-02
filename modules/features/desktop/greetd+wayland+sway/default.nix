{
  flake.features."greetd+wayland+sway" = {
    nixos = { pkgs, ... }: {
      environment.systemPackages = with pkgs; [
        wl-clipboard # Copy/Paste functionality.
        mako # Notification utility.
      ];

      # Enables Gnome Keyring to store secrets for applications.
      services.gnome.gnome-keyring.enable = true;
      security.pam.services = {

        greetd.enableGnomeKeyring = true;
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
