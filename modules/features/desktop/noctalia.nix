{ inputs, ... }:
let
  caches = {
    extra-substituters = [
      "https://noctalia.cachix.org"
      "https://umbriel.cachix.org"
    ];
    extra-trusted-public-keys = [
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      "umbriel.cachix.org-1:JfNq/2yg2S6D6z4Z2dVSZrZlDPQTKtexB6GAVLD98nw="
    ];
  };
in
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

  # A fresh VM's nix.conf lacks the caches until its first switch, and
  # compiling the stack from source runs an 8 GiB VM out of memory. The build
  # recipes accept this flake config so the first build is cached too.
  flake-file.nixConfig = caches;

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

        nix.settings = caches;

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
        config,
        lib,
        pkgs,
        osConfig,
        ...
      }:
      let
        # Remove unused inherited bindings so the live cheatsheet stays concise.
        startingConfig = builtins.fromTOML (builtins.readFile "${inputs.umbriel}/examples/config.toml");
        baseConfig = (pkgs.formats.toml { }).generate "umbriel-base.toml" (
          startingConfig
          // {
            keybinds = builtins.removeAttrs startingConfig.keybinds [
              "Mod+Return"
              "Mod"
              "Mod+H"
              "Mod+J"
              "Mod+K"
              "Mod+L"
              "Mod+F1"
              "Mod+M"
              "Mod+Ctrl+Minus"
              "Mod+Ctrl+Equal"
              "Mod+Shift+Space"
              "Mod+Space"
              "Mod+Ctrl+Space"
              "Mod+Tab"
            ];
          }
        );
      in
      {
        imports = [
          inputs.umbriel.homeModules.default
          inputs.noctalia.homeModules.default
        ];

        home.pointerCursor = lib.mkIf pkgs.stdenv.isLinux {
          package = pkgs.bibata-cursors;
          name = "Bibata-Modern-Classic";
          size = 32;
          gtk.enable = true;
          x11.enable = true;
        };
        gtk.enable = lib.mkIf pkgs.stdenv.isLinux true;

        programs.noctalia = lib.mkIf pkgs.stdenv.isLinux {
          enable = true;
          package = osConfig.programs.noctalia.package;
          settings = {
            bar.default.start = [
              "launcher"
              "wallpaper"
              "workspaces"
              "browser"
            ];
            plugins.enabled = [ "dotfiles/browser-selector" ];
            widget.browser.type = "dotfiles/browser-selector:browser";
          };
        };

        # The desktop profile is shared with Darwin hosts.
        programs.umbriel = lib.mkIf pkgs.stdenv.isLinux {
          enable = true;
          # The NixOS module installs the compositor.
          package = null;
          # Layer overrides on top of Umbriel's packaged starting config.
          settings = {
            include.files = [ baseConfig ];
            general.autostart = [ "noctalia" ];
            input.cursor = {
              theme = config.home.pointerCursor.name;
              size = config.home.pointerCursor.size;
            };
            keybinds =
              (builtins.listToAttrs (
                map (index: {
                  name = "Mod+Alt+${toString index}";
                  value = "column-focus-tab ${toString index}";
                }) (lib.range 1 9)
              ))
              // {
                "Mod+Space" = {
                  action = "spawn noctalia msg panel-toggle launcher";
                  repeat = false;
                };
                "Mod+Left" = "window-focus-or-output-left";
                "Mod+Right" = "window-focus-or-output-right";
                "Mod+Alt+Left" = "column-move-tab-previous";
                "Mod+Alt+Right" = "column-move-tab-next";
                "Mod+Shift+Left" = "window-move-or-output-left";
                "Mod+Shift+Right" = "window-move-or-output-right";
                "Mod+Shift+Minus" = "window-modify-secondary-extent -0.02";
                "Mod+Shift+Equal" = "window-modify-secondary-extent +0.02";
                "Mod+F" = {
                  action = "window-toggle-maximize";
                  repeat = false;
                };
                "Mod+Ctrl+F" = {
                  action = "window-toggle-fullscreen";
                  repeat = false;
                };
                "Mod+grave" = {
                  action = "spawn ghostty";
                  repeat = false;
                };
                "Alt+Tab" = "spawn noctalia msg window-switcher hold";
                "Alt+Shift+Tab" = "spawn noctalia msg window-switcher hold reverse";
                "Mod+Shift+A" = "spawn noctalia msg screenshot-annotate";
                # Native Wayland apps cannot grab global shortcuts here, so the
                # compositor opens 1Password Quick Access instead.
                "Mod+Shift+Space" = {
                  action = "spawn 1password --quick-access";
                  repeat = false;
                };
                "Mod+Slash" = {
                  action = "cheatsheet-toggle";
                  repeat = false;
                };
                "Mod+Ctrl+Left" = "output-focus-left";
                "Mod+Ctrl+Right" = "output-focus-right";
                "Mod+Ctrl+Shift+Left" = "window-move-to-output-left";
                "Mod+Ctrl+Shift+Right" = "window-move-to-output-right";
                "Mod+Comma" = {
                  action = "window-consume-or-expel-left";
                  repeat = false;
                };
                "Mod+Period" = {
                  action = "window-consume-or-expel-right";
                  repeat = false;
                };
              };
          };
        };
      };
  };
}
