{ self, inputs, ... }: {
  flake.nixosConfigurations =
    let
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
            };
          };
      };

      # TODO: Make this a flake input somehow so it can be set to $USER to mirror lima's auto created user.
      username = "hamishwhc";
      mkLimaHost =
        name: args:
        self.lib.mkNixosHost name (
          args
          // {
            inherit username;
            system = "aarch64-linux";
            configDir = "/home/${username}/dotfiles";
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
