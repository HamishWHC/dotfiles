{
  flake.features.macos-preferences = {
    darwin =
      { config, username, ... }:
      {
        system.defaults = {
          NSGlobalDomain = {
            KeyRepeat = 2;
            InitialKeyRepeat = 25;
            NSAutomaticCapitalizationEnabled = false;
            NSAutomaticDashSubstitutionEnabled = false;
            NSAutomaticPeriodSubstitutionEnabled = true;
            NSAutomaticQuoteSubstitutionEnabled = false;
            NSAutomaticSpellingCorrectionEnabled = false;
            AppleICUForce24HourTime = true;
            AppleInterfaceStyle = "Dark";
            AppleShowAllExtensions = true;
            AppleEnableSwipeNavigateWithScrolls = false;
            "com.apple.keyboard.fnState" = false;
            "com.apple.trackpad.forceClick" = true;
          };

          dock = {
            autohide = true;
            orientation = "bottom";
            tilesize = 41;
            magnification = false;
            mineffect = "genie";
            minimize-to-application = false;
            mru-spaces = false;
            showAppExposeGestureEnabled = true;
          };

          WindowManager = {
            EnableTiledWindowMargins = false;
            EnableTilingByEdgeDrag = false;
            EnableTilingOptionAccelerator = false;
            EnableTopTilingByEdgeDrag = false;
          };

          finder = {
            FXPreferredViewStyle = "Nlsv";
            FXDefaultSearchScope = "SCcf";
            NewWindowTarget = "Documents";
            ShowPathbar = true;
            ShowStatusBar = false;
            FXEnableExtensionChangeWarning = false;
            FXRemoveOldTrashItems = true;
            ShowHardDrivesOnDesktop = true;
            ShowExternalHardDrivesOnDesktop = true;
            ShowMountedServersOnDesktop = true;
            ShowRemovableMediaOnDesktop = true;
          };

          # nix-darwin writes these to both built-in and Bluetooth trackpad domains.
          trackpad = {
            Clicking = false;
            TrackpadRightClick = true;
            ForceSuppressed = false;
            TrackpadThreeFingerDrag = false;
            TrackpadThreeFingerVertSwipeGesture = 2;
            TrackpadFourFingerVertSwipeGesture = 2;
            TrackpadTwoFingerFromRightEdgeSwipeGesture = 3;
          };

          screencapture.location = "${config.users.users.${username}.home}/Desktop/Screen Captures";

          menuExtraClock = {
            Show24Hour = true;
            ShowDate = 1;
            ShowDayOfWeek = true;
            ShowSeconds = true;
          };

          universalaccess.closeViewScrollWheelToggle = true;
          hitoolbox.AppleFnUsageType = "Do Nothing";

          CustomUserPreferences = {
            NSGlobalDomain = {
              AppleLanguages = [ "en-AU" ];
              AppleLocale = "en_AU";
              AppleReduceDesktopTinting = true;
              # Preserve the observed completion keys, rather than inferring a
              # value for the separate NSAutomaticInlinePredictionEnabled key.
              NSAutomaticTextCompletionEnabled = true;
              NSAutomaticTextCompletionCollapsed = true;
              WebAutomaticSpellingCorrectionEnabled = false;
            };
            "com.apple.universalaccess".closeViewScrollWheelModifiersInt = 524288; # Option
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
