{
  flake.features.macos = {
    darwin =
      {
        config,
        lib,
        username,
        ...
      }:
      {
        # Reload user preferences so shortcuts take effect in the current session.
        system.activationScripts.postActivation.text = ''
          launchctl asuser "$(id -u ${lib.escapeShellArg username})" \
            sudo -H -u ${lib.escapeShellArg username} \
            /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
        '';

        system.defaults = {
          NSGlobalDomain = {
            AppleICUForce24HourTime = true; # Use 24-hour time
            AppleInterfaceStyle = "Dark"; # Use dark appearance
            AppleShowAllExtensions = true; # Show all filename extensions

            # Trackpad
            AppleEnableSwipeNavigateWithScrolls = false; # Swipe between pages
            "com.apple.trackpad.forceClick" = true; # Enable trackpad Force Click

            # Keyboard
            KeyRepeat = 2; # Delay between repeated keystrokes
            InitialKeyRepeat = 25; # Delay before key repeat
            "com.apple.keyboard.fnState" = false; # Media keys by default

            # Apple's terrible autocorrect and "smart" text features.
            NSAutomaticCapitalizationEnabled = false; # Automatically capitalize typed words
            NSAutomaticDashSubstitutionEnabled = false; # Substitute smart dashes
            NSAutomaticPeriodSubstitutionEnabled = false; # Double-space inserts a period
            NSAutomaticQuoteSubstitutionEnabled = false; # Substitute smart quotation marks
            NSAutomaticSpellingCorrectionEnabled = false; # Automatically correct spelling
            NSAutomaticInlinePredictionEnabled = false; # Predictive text suggestions
          };

          dock = {
            autohide = true; # Automatically hide the Dock
            orientation = "bottom"; # Position Dock at bottom
            tilesize = 40; # Dock icon size
            magnification = false; # Enlarge icons on hover
            mineffect = "genie"; # Window minimization animation
            minimize-to-application = false; # Minimize into application icon
            mru-spaces = false; # Reorder Spaces by recent use
            showAppExposeGestureEnabled = true; # Gesture shows application windows
          };

          WindowManager = {
            EnableTiledWindowMargins = false; # Gaps between tiled windows
            EnableTilingByEdgeDrag = false; # Tile at screen edges
            EnableTilingOptionAccelerator = false; # Hold Option to tile
            EnableTopTilingByEdgeDrag = false; # Fill screen at top edge
          };

          finder = {
            FXPreferredViewStyle = "Nlsv"; # Default to list view
            FXDefaultSearchScope = "SCcf"; # Search the current folder
            NewWindowTarget = "Documents"; # Open Documents in new windows
            ShowPathbar = true; # Show folder path breadcrumbs
            ShowStatusBar = false; # Show item and space counts
            FXEnableExtensionChangeWarning = false; # Warn when changing extensions
            FXRemoveOldTrashItems = true; # Delete trash after 30 days
            ShowHardDrivesOnDesktop = true; # Desktop icons for internal disks
            ShowExternalHardDrivesOnDesktop = true; # Desktop icons for external disks
            ShowMountedServersOnDesktop = true; # Desktop icons for mounted servers
            ShowRemovableMediaOnDesktop = true; # Desktop icons for removable media
          };

          # nix-darwin writes these to both built-in and Bluetooth trackpad domains.
          trackpad = {
            Clicking = false; # Tap trackpad to click
            TrackpadRightClick = true; # Two-finger secondary click
            ForceSuppressed = false; # Suppress trackpad Force Click
            TrackpadThreeFingerDrag = false; # Drag with three fingers
            TrackpadThreeFingerVertSwipeGesture = 2; # Three-finger vertical window gestures
            TrackpadFourFingerVertSwipeGesture = 2; # Four-finger vertical window gestures
            TrackpadTwoFingerFromRightEdgeSwipeGesture = 3; # Swipe opens Notification Center
          };

          screencapture.location = "${config.users.users.${username}.home}/Desktop/Screen Captures"; # Native screenshot save folder

          menuExtraClock = {
            Show24Hour = true; # Use 24-hour clock
            ShowDate = 1; # Always show the date
            ShowDayOfWeek = true; # Show weekday in clock
            ShowSeconds = true; # Show seconds in clock
          };

          # TODO: Figure out why this fails on Atlassian laptops.
          # universalaccess.closeViewScrollWheelToggle = true; # Modifier-scroll zooms the screen
          hitoolbox.AppleFnUsageType = "Do Nothing"; # Action when pressing Fn alone

          CustomUserPreferences = {
            # These keys have no typed NSGlobalDomain options in our nix-darwin pin.
            NSGlobalDomain = {
              # Supported in nix-darwin unstable, update when available.
              AppleReduceDesktopTinting = true; # Reduce wallpaper window tinting

              # Disable more text features that are enabled by default.
              NSAutomaticTextCompletionEnabled = false; # Enable automatic text completion
              NSAutomaticTextCompletionCollapsed = false; # Collapsed text completion setting
              WebAutomaticSpellingCorrectionEnabled = false; # Automatically correct web spelling
            };

            # Hold Option while scrolling to zoom
            # TODO: Figure out why this fails on Atlassian laptops.
            # "com.apple.universalaccess".closeViewScrollWheelModifiersInt = 524288;

            # Ordinary definitions allow other modules to override individual
            # fields with lib.mkForce, including enabled and value.parameters.
            # parameters = [ characterCode virtualKeyCode modifierMask ]; all decimal.

            # Modifier masks (add each held modifier once; equivalently bitwise OR):
            #   Shift = 131072, Control = 262144, Option/Alt = 524288,
            #   Command = 1048576, Fn = 8388608, Caps Lock = 65536.
            #   Example: Command-Shift = 1048576 + 131072 = 1179648.
            # https://developer.apple.com/documentation/coregraphics/cgeventflags

            # For letters/numbers/punctuation, characterCode is the unshifted
            # character's decimal code (ASCII for these Australian-layout keys):
            #   "a" = 97, "3" = 51, "/" = 47. Shift goes in modifierMask.
            # 65535 (0xFFFF) means no character code, as in the Space bindings below.

            # virtualKeyCode identifies the physical key, not its character code:
            #   A = 0, 3 = 20, / = 44, Space = 49 (Australian/US layout).
            # Find letters/digits/punctuation as kVK_ANSI_* in the macOS SDK's
            # Carbon.framework/Frameworks/HIToolbox.framework/Headers/Events.h;
            # convert its hexadecimal values to decimal (e.g. kVK_ANSI_3 = 0x14 = 20).
            # For another layout or an uncertain combination, assign it in System
            # Settings, then inspect: defaults read com.apple.symbolichotkeys AppleSymbolicHotKeys

            "com.apple.symbolichotkeys".AppleSymbolicHotKeys =
              let
                cmd = 1048576;
                shift = 131072;
                ctrl = 262144;
                opt = 524288;
                # fn = 8388608;
                # caps = 65536;
                noChar = 65535;
              in
              {
                "28" = {
                  enabled = true; # Save full-screen screenshot
                  value = {
                    parameters = [
                      # Command-Shift-3
                      51
                      20
                      (cmd + shift)
                    ];
                    type = "standard";
                  };
                };
                "29" = {
                  enabled = true; # Copy full-screen screenshot
                  value = {
                    parameters = [
                      # Command-Control-Shift-3
                      51
                      20
                      (cmd + ctrl + shift)
                    ];
                    type = "standard";
                  };
                };
                "30" = {
                  enabled = true; # Save selected-area screenshot
                  value = {
                    parameters = [
                      # Command-Shift-4
                      52
                      21
                      (cmd + shift)
                    ];
                    type = "standard";
                  };
                };
                "31" = {
                  enabled = true; # Copy selected-area screenshot
                  value = {
                    parameters = [
                      # Command-Control-Shift-4
                      52
                      21
                      (cmd + ctrl + shift)
                    ];
                    type = "standard";
                  };
                };
                "64" = {
                  enabled = true; # Spotlight search
                  value = {
                    parameters = [
                      # Command-Space
                      noChar
                      49
                      cmd
                    ];
                    type = "standard";
                  };
                };
                "65" = {
                  enabled = true; # Spotlight Finder search
                  value = {
                    parameters = [
                      # Command-Option-Space
                      noChar
                      49
                      (cmd + opt)
                    ];
                    type = "standard";
                  };
                };
                "184" = {
                  enabled = true; # Screenshot toolbar (Command-Shift-5)
                  value = {
                    parameters = [
                      # Command-Shift-5
                      53
                      23
                      (cmd + shift)
                    ];
                    type = "standard";
                  };
                };
              };
          };
        };
      };

    homeManager =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      lib.mkIf pkgs.stdenv.isDarwin {
        home.activation.macosPreferences = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          run mkdir -p ${lib.escapeShellArg "${config.home.homeDirectory}/Desktop/Screen Captures"}
        '';
      };
  };
}
