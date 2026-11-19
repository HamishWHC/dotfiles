{
  flake.features.one-password = {
    darwin = {
      homebrew.casks = [ "1password" ];
    };

    homeManager =
      {
        lib,
        options,
        pkgs,
        ...
      }:
      {
        config = lib.mkMerge [
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
          }

          # Only hosts with the Umbriel desktop have this option.
          (lib.optionalAttrs (options ? programs.umbriel) {
            programs.umbriel.settings = lib.mkIf pkgs.stdenv.isLinux {
              # Tray only, so the SSH agent and Quick Access are available.
              # After Noctalia, which provides the tray.
              general.autostart = lib.mkAfter [ "1password --silent" ];

              # Native Wayland apps cannot grab global shortcuts here, so the
              # compositor opens 1Password Quick Access instead.
              keybinds."Mod+Shift+Space" = {
                action = "spawn 1password --quick-access";
                repeat = false;
              };
            };
          })
        ];
      };
  };
}
