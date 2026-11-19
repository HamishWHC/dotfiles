{ self, ... }:
{
  flake.nixosConfigurations.gaming = self.lib.mkNixosHost "gaming" {
    system = "x86_64-linux";
    username = "hamishwhc";
    configDir = "/home/hamishwhc/Documents/Projects/dotfiles";
    features = [
      self.profiles.gaming
      {
        homeManager = {
          programs.umbriel.settings.output = {
            # Physical left-to-right order. Positions use logical pixels:
            # 3840 / 1.5 = 2560, so the displays meet at their inner edges.
            "Dell Inc. AW3225QF 67R8YZ3" = {
              position = [ 0 0 ];
              scale = 1.5;
            };
            "Samsung Electric Company LS32A70 HNATB00100" = {
              position = [ 2560 0 ];
              scale = 1.5;
            };
          };

          # Lock screen on the Dell only, matched by model rather than port.
          programs.noctalia.settings.lockscreen.monitors = [ "AW3225QF" ];
        };

        nixos =
          { config, pkgs, ... }:
          {
            imports = [ ./_hardware-configuration.nix ];

            networking.hostName = "gaming";

            # Show the login screen on the main monitor only.
            services.displayManager.noctalia-greeter.settings.output.name =
              "Dell Inc. AW3225QF 67R8YZ3";

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

            # Audeze Maxwell: the dongle has two hardware outputs, hw:N,0
            # "Chat" (with the mic) and hw:N,1 "Game", and mixes them itself
            # according to the headset's Game/Chat dial. PipeWire's bundled
            # usb-gaming-headset profile set exposes both as separate sinks.
            services.pipewire.wireplumber.extraConfig."51-audeze-maxwell" = {
              "monitor.alsa.rules" = [
                {
                  matches = [ { "device.name" = "~alsa_card\\.usb-Audeze_LLC_Audeze_Maxwell.*"; } ];
                  actions.update-props = {
                    "device.profile-set" = "usb-gaming-headset.conf";
                    "device.profile" = "output:stereo-game+output:stereo-chat+input:mono-chat";
                  };
                }
                {
                  matches = [ { "node.name" = "~alsa_output\\.usb-Audeze_LLC_Audeze_Maxwell.*\\.stereo-game$"; } ];
                  actions.update-props = {
                    "node.description" = "Audeze Maxwell Game";
                    "node.nick" = "Maxwell Game";
                    "priority.session" = 1100;
                    "priority.driver" = 1100;
                  };
                }
                {
                  matches = [ { "node.name" = "~alsa_output\\.usb-Audeze_LLC_Audeze_Maxwell.*\\.stereo-chat$"; } ];
                  actions.update-props = {
                    "node.description" = "Audeze Maxwell Chat";
                    "node.nick" = "Maxwell Chat";
                    "priority.session" = 1000;
                    "priority.driver" = 1000;
                  };
                }
                {
                  matches = [ { "node.name" = "~alsa_input\\.usb-Audeze_LLC_Audeze_Maxwell.*"; } ];
                  actions.update-props = {
                    "node.description" = "Audeze Maxwell Microphone";
                    "node.nick" = "Maxwell Mic";
                  };
                }
              ];
            };

            # RTX 4070 Ti.
            services.xserver.videoDrivers = [ "nvidia" ];
            hardware = {
              graphics.enable = true;
              nvidia = {
                open = true;
                modesetting.enable = true;
                # Save video memory across suspend; otherwise GPU clients crash
                # on resume.
                powerManagement.enable = true;
                package = config.boot.kernelPackages.nvidiaPackages.stable;
              };
            };
          };
      }
    ];
  };
}
