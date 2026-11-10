{ self, inputs, ... }:
let
  runtimeFile = ../../utm/runtime.json;
  runtime =
    if builtins.pathExists runtimeFile then
      builtins.fromJSON (builtins.readFile runtimeFile)
    else
      {
        # Keep pure Git-flake evaluation working before a utm-* recipe has
        # generated the instance-specific runtime values.
        username = "hamishwhc";
        sshPublicKey = null;
      };
  username = runtime.username;
  configDir = "/home/${username}/dotfiles";

  # Shared by the hosts and the bootstrap image, so a VM created from the
  # image is reachable over SSH and can receive the worktree before its first switch.
  utmGuestModule =
    {
      lib,
      modulesPath,
      pkgs,
      host,
      ...
    }:
    {
      imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

      networking.hostName = host;

      services = {
        openssh.enable = true;
        # utmctl's exec, file and ip-address commands go through the agent.
        # No spice-vdagentd: its clipboard and resize support is X11-only, and
        # UTM only resizes QEMU displays when that agent reports support.
        qemuGuest.enable = true;
      };

      users.users.${username} = {
        isNormalUser = true;
        # Matches the Lima hosts; the Noctalia greeter hides users below 1000.
        uid = 1000;
        home = "/home/${username}";
        extraGroups = [ "wheel" ];
        initialPassword = "verysecure";
        openssh.authorizedKeys.keys = lib.optional (runtime.sshPublicKey != null) runtime.sshPublicKey;
      };

      security.sudo.wheelNeedsPassword = false;

      # The utm-* recipes rsync the worktree to configDir instead of sharing it:
      # UTM's VirtFS share reports host UIDs, so the guest user can't write to
      # it, and it can't read symlinks created on the host.
      environment.systemPackages = [ pkgs.rsync ];

      # QEMU's accelerated virtio-gpu draws the hardware cursor plane flipped
      # and offset from the pointer. This makes wlroots compositors such as
      # the greeter's draw it in software.
      environment.sessionVariables.WLR_NO_HARDWARE_CURSORS = "1";

      # Matches the layout of the bootstrap qemu-efi image.
      boot = {
        loader = {
          grub.enable = false;
          systemd-boot.enable = true;
        };
        growPartition = true;
        kernelPackages = pkgs.linuxPackages_latest;
      };

      fileSystems = {
        "/" = {
          device = "/dev/disk/by-label/nixos";
          autoResize = true;
          fsType = "ext4";
        };
        "/boot" = {
          device = "/dev/disk/by-label/ESP";
          fsType = "vfat";
        };
      };
    };

  utmGuestHomeModule =
    { lib, pkgs, ... }:
    lib.mkIf pkgs.stdenv.isLinux {
      programs.umbriel.settings = {
        # See WLR_NO_HARDWARE_CURSORS; this is Umbriel's own setting.
        input.cursor.hardware_cursor = false;
        # The VM display is a fixed native (Retina) resolution; see utm/recipes.just.
        output.Virtual-1.scale = 1.25;
      };
    };

  mkUtmHost =
    name:
    args@{
      features ? [ ],
      ...
    }:
    self.lib.mkNixosHost name (
      args
      // {
        inherit username configDir;
        system = "aarch64-linux";
        features = [
          {
            nixos = utmGuestModule;
            homeManager = utmGuestHomeModule;
          }
        ]
        ++ features;
      }
    );

  # Only the guest essentials; utm-start switches it to the real host, which
  # builds natively in the VM instead of copying a full image out of Lima.
  bootstrap = inputs.nixpkgs.lib.nixosSystem {
    system = "aarch64-linux";
    specialArgs.host = "utm-nixos-bootstrap";
    modules = [
      utmGuestModule
      {
        system.stateVersion = "26.05";
        nix.settings = {
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          trusted-users = [
            "root"
            "@wheel"
          ];
        };
      }
    ];
  };
in
{
  flake.nixosConfigurations.utm-nixos-gaming = mkUtmHost "utm-nixos-gaming" {
    features = [ self.profiles.desktop ];
  };

  flake.packages.aarch64-linux.utm-bootstrap-image = bootstrap.config.system.build.images.qemu-efi;
}
