{ self, inputs, ... }: {
  flake.nixosConfigurations =
    let
      runtimeFile = ../../lima/runtime.json;
      runtime =
        if builtins.pathExists runtimeFile then
          builtins.fromJSON (builtins.readFile runtimeFile)
        else
          {
            # Keep pure Git-flake evaluation working before lima-start has
            # generated the instance-specific runtime values.
            username = "hamishwhc";
            hostPath = "/Users/hamishwhc/Documents/Projects/dotfiles";
          };
      username = runtime.username;
      configDir = "/home/${username}/dotfiles";
      mountTag =
        "lima-${
          builtins.substring 0 16 (
            builtins.hashString "sha256" "${runtime.hostPath}:${configDir}"
          )
        }";

      limaGuestHostFeature = {
        nixos =
          {
            lib,
            modulesPath,
            pkgs,
            host,
            ...
          }:
          {
            imports = [
              inputs.nixos-lima.nixosModules.lima
              (modulesPath + "/profiles/qemu-guest.nix")
            ];

            networking.hostName = host;

            services = {
              lima.enable = true;
              openssh.enable = true;
            };

            users = {
              # lima-init creates the login user and injects its SSH key. A
              # mutable user preserves those runtime-managed credentials.
              mutableUsers = true;
              users.${username} = {
                isNormalUser = true;
                home = "/home/${username}";
                extraGroups = [ "wheel" ];
                password = "verysecure";
              };
            };

            security.sudo.wheelNeedsPassword = false;

            # Match the partition layout used by the released nixos-lima
            # images. The guest profile supplies the virtio drivers needed by
            # both Lima's QEMU and VZ backends.
            boot = {
              loader.grub = {
                device = "nodev";
                efiSupport = true;
                efiInstallAsRemovable = true;
              };
              kernelPackages = pkgs.linuxPackages_latest;
              # Keep the released image's serial consoles while making tty0
              # the active console whenever a virtual monitor is attached.
              kernelParams = [
                "console=ttyS0"
                "console=ttyAMA0,115200"
                "console=tty0"
              ];
            };

            fileSystems = {
              "/boot" = {
                device = lib.mkForce "/dev/vda1";
                fsType = "vfat";
              };
              "/" = {
                device = "/dev/disk/by-label/nixos";
                autoResize = true;
                fsType = "ext4";
                options = [
                  "noatime"
                  "nodiratime"
                  "discard"
                ];
              };
              "${configDir}" = {
                device = mountTag;
                fsType = "virtiofs";
                options = [
                  "rw"
                  "nofail"
                ];
              };
            };
          };
      };

      mkLimaHost =
        name: args:
        self.lib.mkNixosHost name (
          args
          // {
            inherit username configDir;
            system = "aarch64-linux";
            features = [
              limaGuestHostFeature
            ]
            ++ args.features;
          }
        );
    in
    {
      lima-nixos-server = mkLimaHost "lima-nixos-server" { };
      lima-nixos-workstation = mkLimaHost "lima-nixos-workstation" {
        features = [ self.profiles.workstation ];
      };
      lima-nixos-gaming = mkLimaHost "lima-nixos-gaming" {
        features = [ self.profiles.desktop ];
      };
    };
}
