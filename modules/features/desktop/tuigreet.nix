{
  flake.features.tuigreet = {
    nixos =
      {
        pkgs,
        config,
        lib,
        ...
      }:
      {
        security.pam.services = lib.mkIf (config.services.gnome.gnome-keyring.enable) {
          greetd.enableGnomeKeyring = true;
        };

        services.greetd = {
          enable = true;
          useTextGreeter = true;
          settings = {
            default_session = {
              command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-user-session";
              user = "greeter";
            };
          };
        };
      };
  };
}
