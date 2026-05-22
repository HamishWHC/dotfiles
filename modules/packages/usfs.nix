{
  perSystem = {pkgs, ...}: {
    packages.usfs = pkgs.writeShellApplication {
      name = "usfs";
      runtimeInputs = [ pkgs.unixtools.umount ];
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
}