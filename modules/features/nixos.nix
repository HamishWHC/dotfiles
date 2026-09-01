{
  flake.features.nixos = {
    nixos =
      {
        username,
        ...
      }:
      {
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
