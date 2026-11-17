{
  flake.features.one-password = {
    darwin = {
      homebrew.casks = [ "1password" ];
    };

    homeManager =
      { lib, pkgs, ... }:
      {
        home.packages = lib.mkIf (pkgs.stdenv.isLinux) [
          pkgs.unstable._1password-gui
        ];

        dotfiles.ssh-client.agents = [
          (
            if pkgs.stdenv.isDarwin then
              "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
            else
              "~/.1password/agent.sock"
          )
        ];
      };
  };
}
