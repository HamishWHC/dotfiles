{
  flake.features.nixos = {
    nixos =
      {
        username,
        ...
      }:
      {
        time.timeZone = "Australia/Sydney";
        i18n = {
          defaultLocale = "en_AU.UTF-8";
          # English with ISO 8601 dates (2026-11-19) and 24-hour time.
          extraLocaleSettings.LC_TIME = "en_DK.UTF-8";
        };
        users.users.${username} = {
          isNormalUser = true;
          home = "/home/${username}";
          extraGroups = [ "wheel" ];
        };
        system.stateVersion = "26.05";

        # Intentionally do not set networking.hostName, networking.computerName, or
        # networking.localHostName. The flake host names are friendly names only.
      };
  };
}
