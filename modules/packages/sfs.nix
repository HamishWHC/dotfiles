{
  perSystem = {pkgs, ...}: {
    packages.sfs = pkgs.writeShellApplication {
      name = "sfs";
      runtimeInputs = [
        pkgs.sshfs
        pkgs.unixtools.umount
      ];
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
  };
}