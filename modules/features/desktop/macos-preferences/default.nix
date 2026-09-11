{
  flake.features.macos-preferences = {
    darwin =
      { config, username, ... }:
      {
        system.defaults = {
          NSGlobalDomain = {
            KeyRepeat = 2; # Delay between repeated keystrokes
            InitialKeyRepeat = 25; # Delay before key repeat
            NSAutomaticCapitalizationEnabled = false; # Automatically capitalize typed words
            NSAutomaticDashSubstitutionEnabled = false; # Substitute smart dashes
            NSAutomaticPeriodSubstitutionEnabled = true; # Double-space inserts a period
            NSAutomaticQuoteSubstitutionEnabled = false; # Substitute smart quotation marks
            NSAutomaticSpellingCorrectionEnabled = false; # Automatically correct spelling
            AppleICUForce24HourTime = true; # Use 24-hour time
            AppleInterfaceStyle = "Dark"; # Use dark appearance
            AppleShowAllExtensions = true; # Show all filename extensions
            AppleEnableSwipeNavigateWithScrolls = false; # Swipe between pages
            "com.apple.keyboard.fnState" = false; # Media keys by default
            "com.apple.trackpad.forceClick" = true; # Enable trackpad Force Click
          };

          dock = {
            autohide = true; # Automatically hide the Dock
            orientation = "bottom"; # Position Dock at bottom
            tilesize = 41; # Dock icon size
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

          universalaccess.closeViewScrollWheelToggle = true; # Modifier-scroll zooms the screen
          hitoolbox.AppleFnUsageType = "Do Nothing"; # Action when pressing Fn alone

          CustomUserPreferences = {
            NSGlobalDomain = {
              AppleLanguages = [ "en-AU" ]; # Prefer Australian English
              AppleLocale = "en_AU"; # Australian regional formatting
              AppleReduceDesktopTinting = true; # Reduce wallpaper window tinting
              # Preserve the observed completion keys, rather than inferring a
              # value for the separate NSAutomaticInlinePredictionEnabled key.
              NSAutomaticTextCompletionEnabled = true; # Enable automatic text completion
              NSAutomaticTextCompletionCollapsed = true; # Collapsed text completion setting
              WebAutomaticSpellingCorrectionEnabled = false; # Automatically correct web spelling
            };
            "com.apple.universalaccess".closeViewScrollWheelModifiersInt = 524288; # Hold Option while zooming
          };

          # Spotlight and screenshot shortcuts belong to Raycast and Shottr.
          # Do not manage com.apple.symbolichotkeys in this feature.
        };
      };

    homeManager =
      { config, lib, pkgs, ... }:
      let
        # The writer checks Python syntax/style during the permitted Nix builds.
        inputPreferences = pkgs.writers.writePython3 "macos-input-preferences" {
          flakeIgnore = [ "E501" ];
        } (builtins.readFile ./input-preferences.py);
      in
      lib.mkIf pkgs.stdenv.isDarwin {
        home.activation.macosPreferences = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          run mkdir -p ${lib.escapeShellArg "${config.home.homeDirectory}/Desktop/Screen Captures"}
          run ${inputPreferences}
        '';
      };
  };
}
