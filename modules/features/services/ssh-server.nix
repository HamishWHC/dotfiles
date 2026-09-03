{
  flake.features.ssh-server = {
    nixos = {
      services.openssh.enable = true;
    };
  };
}
