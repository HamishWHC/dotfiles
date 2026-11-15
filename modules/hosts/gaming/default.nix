{ self, ... }:
{
  flake.nixosConfigurations.gaming = self.lib.mkNixosHost "gaming" {
    system = "x86_64-linux";
    username = "hamishwhc";
    configDir = "/home/hamishwhc/Documents/Projects/dotfiles";
    features = [
      self.profiles.gaming
      {
        nixos =
          { config, pkgs, ... }:
          {
            imports = [ ./_hardware-configuration.nix ];

            networking.hostName = "gaming";

            boot.loader = {
              efi.canTouchEfiVariables = true;
              systemd-boot = {
                enable = true;
                configurationLimit = 10;
                # Windows keeps its own ESP on the other drive, so systemd-boot
                # chainloads its boot manager through the EDK2 shell.
                # `efiDeviceHandle` comes from `map -c` in the shell's own entry.
                edk2-uefi-shell.enable = true;
                windows."11" = {
                  title = "Windows 11";
                  efiDeviceHandle = "HD1b";
                };
              };
            };

            environment.systemPackages = [
              (pkgs.writeShellApplication {
                name = "reboot-windows";
                text = "systemctl reboot --boot-loader-entry=windows_11.conf";
              })
            ];

            # RTX 4070 Ti.
            services.xserver.videoDrivers = [ "nvidia" ];
            hardware = {
              graphics.enable = true;
              nvidia = {
                open = true;
                modesetting.enable = true;
                package = config.boot.kernelPackages.nvidiaPackages.stable;
              };
            };
          };
      }
    ];
  };
}
