{ inputs, ... }:
{
  # No `inputs.nixpkgs.follows`: overriding nixpkgs changes the derivations and
  # misses the Cachix caches. The `cachix` branches only advance once CI has
  # cached a commit. The greeter has no cache, so it follows nixpkgs-unstable,
  # which it is developed against.
  flake-file.inputs = {
    noctalia.url = "github:noctalia-dev/noctalia/cachix";
    umbriel.url = "github:noctalia-dev/umbriel/cachix";
    noctalia-greeter = {
      url = "github:noctalia-dev/noctalia-greeter";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  flake.features.noctalia = {
    nixos =
      {
        config,
        lib,
        pkgs,
        username,
        ...
      }:
      {
        imports = [
          inputs.noctalia.nixosModules.default
          inputs.umbriel.nixosModules.default
          inputs.noctalia-greeter.nixosModules.default
        ];

        nix.settings = {
          extra-substituters = [
            "https://noctalia.cachix.org"
            "https://umbriel.cachix.org"
          ];
          extra-trusted-public-keys = [
            "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
            "umbriel.cachix.org-1:JfNq/2yg2S6D6z4Z2dVSZrZlDPQTKtexB6GAVLD98nw="
          ];
        };

        programs.umbriel.enable = true;

        programs.noctalia = {
          enable = true;
          # NetworkManager, Bluetooth, UPower and power-profiles-daemon back
          # the shell's network, bluetooth, battery and power widgets.
          recommendedServices.enable = true;
        };

        services.displayManager.noctalia-greeter = {
          enable = true;
          settings = {
            session.default = "Umbriel";
            user.default = username;
          };
          # Lets the shell sync its wallpaper and palette to the greeter
          # without an admin prompt.
          passwordless-sync-users = [ username ];
        };

        # The shell's lock screen authenticates against `login`, which the
        # gnome-keyring module already unlocks the keyring for.
        security.pam.services = lib.mkIf config.services.gnome.gnome-keyring.enable {
          greetd.enableGnomeKeyring = true;
        };

        environment.systemPackages = [ pkgs.wl-clipboard ];
      };

    homeManager =
      {
        lib,
        pkgs,
        osConfig,
        ...
      }:
      {
        imports = [ inputs.umbriel.homeModules.default ];

        # The desktop profile is shared with Darwin hosts.
        programs.umbriel = lib.mkIf pkgs.stdenv.isLinux {
          enable = true;
          # The NixOS module installs the compositor.
          package = null;
          # Layer overrides on top of Umbriel's packaged starting config.
          settings = {
            include.files = [ "${osConfig.programs.umbriel.package}/share/umbriel/config.toml" ];
            general.autostart = [ "noctalia" ];
            keybinds = {
              "Mod+Return" = {
                action = "spawn ghostty";
                repeat = false;
              };
              "Mod+S" = "spawn noctalia msg panel-toggle control-center";
              "Mod+Shift+Comma" = "spawn noctalia msg settings-toggle";
              "Alt+Tab" = "spawn noctalia msg window-switcher hold";
              "Alt+Shift+Tab" = "spawn noctalia msg window-switcher hold reverse";
              "Mod+Shift+A" = "spawn noctalia msg screenshot-annotate";
            };
          };
        };
      };
  };
}
