{
  flake.features.secretive = {
    homeManager =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      lib.mkIf (pkgs.stdenv.isDarwin) {
        dotfiles.ssh-client.agents = [
          "${config.home.homeDirectory}/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh"
        ];
      };

    darwin = {
      homebrew.casks = [ "secretive" ];
    };
  };
}
