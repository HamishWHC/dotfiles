{ inputs, ... }:
{
  perSystem = { pkgs, system, ... }: {
    packages = {
      cat = inputs.wrappers.lib.wrapPackage {
        inherit pkgs;
        package = pkgs.bat;
        exePath = "${pkgs.bat}/bin/bat";
        binName = "cat";
        args = [ "--paging=never" ];
      };

      grep = inputs.wrappers.lib.wrapPackage {
        inherit pkgs;
        package = pkgs.gnugrep;
        exePath = "${pkgs.gnugrep}/bin/grep";
        flags = {
          "--color" = true;
        };
      };

      ls = inputs.wrappers.lib.wrapPackage {
        inherit pkgs;
        package = pkgs.coreutils;
        exePath = "${pkgs.coreutils}/bin/ls";
        flags = {
          "-h" = true;
          "--color" = "auto";
        };
        flagSeparator = "=";
      };

      sfs = pkgs.writeShellApplication {
        name = "sfs";
        runtimeInputs = [ pkgs.sshfs ];
        text = ''
          if [ "$#" -ne 1 ]; then
            echo "Usage: sfs <target>"
            exit 1
          fi

          target="$1"
          mkdir -p "$HOME/mounts/''${target}"
          umount -f "$HOME/mounts/''${target}" 2>/dev/null || true
          sshfs -o idmap=user -C "''${target}:" "$HOME/mounts/''${target}"
        '';
      };

      usfs = pkgs.writeShellApplication {
        name = "usfs";
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
