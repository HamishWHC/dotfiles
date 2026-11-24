{ inputs, ... }:
{
  flake-file.inputs = {
    homebrew-acsandmann-tap = {
      url = "github:acsandmann/homebrew-tap";
      flake = false;
    };
  };

  # Rift: a tiling window manager with a scrolling layout, configured to match
  # the Umbriel binds in ../../desktop/noctalia.nix.
  #
  # Umbriel's Mod (Super) is Control-Option here, Mod+Ctrl is Control-Option-Command.
  #
  # Multi-display: Rift picks display neighbours from the macOS arrangement and
  # its scrolling layout can leak off-screen columns onto a display beside the
  # current one. At home, arrange the side-by-side monitors diagonally in macOS
  # (left monitor up-left, touching the right monitor only at a corner): Rift
  # then treats the other monitor as both right and down, nothing sits beside
  # either display, and horizontal_mouse_warp lets the pointer cross sideways.
  # Vertically stacked (hot desk) displays need nothing: up/down binds cross
  # them, and the warp only acts at left/right screen edges.
  flake.features.rift = {
    darwin = {
      nix-homebrew = {
        taps."acsandmann/homebrew-tap" = inputs.homebrew-acsandmann-tap;
        trust.formulae = [ "acsandmann/tap/rift" ];
      };
      homebrew.brews = [ "acsandmann/tap/rift" ];

      # Rift requires "Displays have separate Spaces".
      system.defaults.spaces.spans-displays = false;
    };

    homeManager =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        label = "git.acsandmann.rift";
        # The formula's stable path; Rift resolves the Cellar path back to it.
        rift = "/opt/homebrew/opt/rift/Rift.app/Contents/MacOS/rift";

        mod = "Ctrl + Alt";
        modShift = "Ctrl + Alt + Shift";
        modCtrl = "Ctrl + Alt + Meta";
        modCtrlShift = "Ctrl + Alt + Meta + Shift";

        directions = [
          "Left"
          "Right"
          "Up"
          "Down"
        ];
        perDirection =
          prefix: command:
          lib.listToAttrs (
            map (key: {
              name = "${prefix} + ${key}";
              value = command (lib.toLower key);
            }) directions
          );
        perWorkspace =
          prefix: command:
          lib.listToAttrs (
            map (index: {
              name = "${prefix} + ${toString index}";
              # Rift numbers workspaces from 0.
              value = command (index - 1);
            }) (lib.range 1 9)
          );

        settings = {
          settings = {
            animate = true;
            # Hover focus raises tiled windows over floating ones; focus on
            # click or keybind only.
            focus_follows_mouse = false;
            mouse_follows_focus = true;
            mouse_hides_on_focus = true;
            # Manage every Space without activating it first.
            default_disable = false;
            # The top display in the macOS arrangement is the physical left one.
            horizontal_mouse_warp = "top-to-bottom";
            hot_reload = true;

            layout = {
              mode = "scrolling";
              scrolling = {
                # Umbriel: new columns start at half the width, presets cycle thirds.
                column_width_ratio = 0.5;
                preset_column_widths = [
                  0.333
                  0.5
                  0.667
                ];
                preserve_window_sizes = false;
                gestures = {
                  enabled = true;
                  invert_horizontal = true;
                };
              };
              # Matches Rectangle's gapSize.
              gaps = {
                outer = {
                  top = 10;
                  left = 10;
                  bottom = 10;
                  right = 10;
                };
                inner = {
                  horizontal = 10;
                  vertical = 10;
                };
              };
            };

            ui = {
              menu_bar.enabled = true;
              mission_control.enabled = true;
            };
          };

          # Umbriel keeps independent workspaces per output.
          virtual_workspaces = {
            mode = "per_display";
            default_workspace_count = 9;
          };

          keys =
            perDirection mod (direction: {
              move_focus = direction;
            })
            // perDirection modShift (direction: {
              move_node = direction;
            })
            // perDirection modCtrl (direction: {
              focus_display = direction;
            })
            // perDirection modCtrlShift (direction: {
              move_window_to_display.selector = direction;
            })
            // perWorkspace mod (index: {
              switch_to_workspace = index;
            })
            // perWorkspace modShift (index: {
              move_window_to_workspace = index;
            })
            // {
              # Shift moves, so it floats the window; plain T moves focus.
              "${mod} + T" = "toggle_focus_floating";
              "${modShift} + T" = "toggle_window_floating";
              "${mod} + F" = "toggle_fullscreen_within_gaps"; # Umbriel's maximize
              "${modCtrl} + F" = "toggle_fullscreen";

              "${mod} + R" = "switch_preset_column_width";
              "${modShift} + R".switch_preset_column_width.backwards = true;
              "${mod} + Minus".resize_window_by.amount = -0.02;
              "${mod} + Equal".resize_window_by.amount = 0.02;
              # Rift's vertical resize step is fixed at 5%.
              "${modShift} + Minus".resize_window_shrink = "vertical";
              "${modShift} + Equal".resize_window_grow = "vertical";
              "${mod} + Comma".consume_or_expel_window = "left";
              "${mod} + Period".consume_or_expel_window = "right";

              "${mod} + O" = "show_mission_control_all";
            };
        };
      in
      lib.mkIf pkgs.stdenv.isDarwin {
        xdg.configFile."rift/config.toml" = {
          source = (pkgs.formats.toml { }).generate "rift-config.toml" settings;
          # Hot reload misses the symlink swap, and Overview needs a restart.
          onChange = ''
            run /bin/launchctl kickstart -k "gui/$(/usr/bin/id -u)/${label}" || true
          '';
        };

        # Matches `rift service install`; Rift leaves a managed symlink alone.
        launchd.agents.${label} = {
          enable = true;
          config = {
            # Keep Rift's own label so `rift service` commands find this job.
            Label = label;
            ProgramArguments = [ rift ];
            EnvironmentVariables.PATH = lib.concatStringsSep ":" [
              "${config.home.profileDirectory}/bin"
              "/run/current-system/sw/bin"
              "/opt/homebrew/bin"
              "/usr/bin"
              "/bin"
              "/usr/sbin"
              "/sbin"
            ];
            RunAtLoad = true;
            KeepAlive = {
              SuccessfulExit = false;
              Crashed = true;
            };
            ProcessType = "Interactive";
            LimitLoadToSessionType = "Aqua";
            Nice = -20;
            StandardOutPath = "/tmp/rift_${config.home.username}.out.log";
            StandardErrorPath = "/tmp/rift_${config.home.username}.err.log";
          };
        };
      };
  };
}
