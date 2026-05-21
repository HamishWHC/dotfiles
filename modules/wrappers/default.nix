{inputs, ...}: {
  perSystem = {
    pkgs,
    ...
  }: let
    wrappers = inputs.wrappers.lib;
  in {
    packages = {
      cat = wrappers.wrapPackage {
        inherit pkgs;
        package = pkgs.bat;
        aliases = ["cat"];
        flags = {
          paging = "never";
        };
      };

      grep = wrappers.wrapPackage {
        inherit pkgs;
        package = pkgs.gnugrep;
        aliases = ["grep"];
        flags = {
          color = "auto";
        };
      };

      ls = wrappers.wrapPackage {
        inherit pkgs;
        package = pkgs.coreutils;
        exePath = "${pkgs.coreutils}/bin/ls";
        aliases = ["ls"];
        flags = {
          h = true;
          color = "auto";
        };
      };

      sfs = pkgs.writeShellApplication {
        name = "sfs";
        runtimeInputs = [pkgs.sshfs pkgs.unixtools.umount];
        text = ''
          if [ "$#" -ne 1 ]; then
            echo "Usage: sfs <target>"
            exit 1
          fi

          target="$1"
          mkdir -p "$HOME/mounts/''${target}"
          umount -f "$HOME/mounts/''${target}" || true
          sshfs -o idmap=user -C "''${target}:" "$HOME/mounts/''${target}"
        '';
      };

      usfs = pkgs.writeShellApplication {
        name = "usfs";
        runtimeInputs = [pkgs.unixtools.umount];
        text = ''
          if [ "$#" -ne 1 ]; then
            echo "Usage: usfs <target>"
            exit 1
          fi

          target="$1"
          umount -f "$HOME/mounts/''${target}"
        '';
      };
    };
  };
}
