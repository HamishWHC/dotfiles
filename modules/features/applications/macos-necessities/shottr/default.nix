{
  flake.features.shottr = {
    homeManager =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        # Carbon modifiers: Command = 256, Shift = 512, Option = 2048, Control = 4096.
        # Key codes are kVK_ANSI_* from HIToolbox's Events.h, in decimal.
        commandShift = 768;
        controlCommandShift = 4864;
        shortcut = modifiers: key: builtins.toJSON {
          carbonKeyCode = key;
          carbonModifiers = modifiers;
        };
        settings = pkgs.writeText "shottr-settings.json" (builtins.toJSON {
          KeyboardShortcuts_ocr = shortcut commandShift 18; # Command-Shift-1
          KeyboardShortcuts_anyWindow = shortcut commandShift 19; # Command-Shift-2
          KeyboardShortcuts_fullscreen = shortcut commandShift 20; # Command-Shift-3
          KeyboardShortcuts_area = shortcut commandShift 21; # Command-Shift-4
          KeyboardShortcuts_scrolling = shortcut controlCommandShift 21; # Control-Command-Shift-4

          # After capture: copy and show the result, without saving a file.
          afterGrabCopy = true;
          afterGrabSave = false;
          afterGrabShow = true;
          copyOnEsc = true;
          saveOnEsc = false;

          saveFormat = "Auto";
          downscaleOnSave = false;
        });
        # Run tests on the setup script to ensure it is working correctly before using it in activation.
        setup = pkgs.runCommand "setup-shottr.py" { } ''
          ${pkgs.python3}/bin/python3 ${./test-setup.py} ${./setup.py}
          cp ${./setup.py} "$out"
        '';
        app = "${config.home.homeDirectory}/${config.targets.darwin.copyApps.directory}/Shottr.app";
      in
      lib.mkIf pkgs.stdenv.isDarwin {
        home.packages = [ pkgs.unstable.shottr ];

        sops.secrets.shottr-license-key = {
          key = "shottr_license_key";
          mode = "0400";
        };

        home.activation.setupShottr =
          lib.hm.dag.entryAfter
            [
              "copyApps"
              "sops-nix"
            ]
            ''
              run ${pkgs.python3}/bin/python3 ${setup} \
                ${settings} \
                ${lib.escapeShellArg app} \
                ${lib.escapeShellArg config.home.homeDirectory} \
                ${lib.escapeShellArg config.sops.secrets.shottr-license-key.path}
            '';
      };

    darwin =
      { lib, ... }:
      {
        # Hand screenshots to Shottr, retaining the native shortcuts' existing bindings.
        system.defaults.CustomUserPreferences."com.apple.symbolichotkeys".AppleSymbolicHotKeys = {
          "28".enabled = lib.mkForce false; # Save full-screen screenshot
          "29".enabled = lib.mkForce false; # Copy full-screen screenshot
          "30".enabled = lib.mkForce false; # Save selected-area screenshot
          "31".enabled = lib.mkForce false; # Copy selected-area screenshot
          "184".enabled = lib.mkForce false; # Screenshot toolbar
          "261".enabled = false; # Ask Siri about selected area
        };
      };
  };
}
