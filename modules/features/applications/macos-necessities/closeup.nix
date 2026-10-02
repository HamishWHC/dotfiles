{ inputs, ... }:
{
  flake-file.inputs.homebrew-oomol = {
    url = "github:oomol-lab/homebrew-tap";
    flake = false;
  };

  flake.features.closeup.darwin =
    { config, lib, ... }:
    let
      user = lib.escapeShellArg config.system.primaryUser;
      # Carbon modifier masks, unlike the CoreGraphics masks in macos.nix.
      cmd = 256;
      opt = 2048;
      shortcut = carbonKeyCode: carbonModifiers: builtins.toJSON {
        inherit carbonKeyCode carbonModifiers;
      };
      overlaySettings = {
        showClose = true;
        showMinimize = false;
        showZoom = false;
      };
    in
    {
      nix-homebrew.taps."oomol-lab/homebrew-tap" = inputs.homebrew-oomol;
      nix-homebrew.trust.casks = [ "oomol-lab/tap/closeup" ];
      homebrew.casks = [ "oomol-lab/tap/closeup" ];

      system.defaults.CustomUserPreferences."com.oomol.CloseUp" = {
        isEnabled = true;
        hideMenuBarIcon = true;
        SUEnableAutomaticChecks = false;
        usesBetaChannel = false;

        # These shortcuts apply while Mission Control is open.
        KeyboardShortcuts_closeWindow = shortcut 13 cmd; # Command-W
        KeyboardShortcuts_closeAllWindows = shortcut 13 (cmd + opt); # Command-Option-W
        KeyboardShortcuts_hideApp = shortcut 4 cmd; # Command-H
        KeyboardShortcuts_hideAllExceptHovered = shortcut 4 (cmd + opt); # Command-Option-H
        KeyboardShortcuts_minimizeWindow = shortcut 46 cmd; # Command-M
        KeyboardShortcuts_minimizeAllWindows = shortcut 46 (cmd + opt); # Command-Option-M
        KeyboardShortcuts_quitApp = shortcut 12 cmd; # Command-Q
        KeyboardShortcuts_zoomWindow = shortcut 3 cmd; # Command-F
      };

      # CloseUp decodes overlaySettings from plist Data containing JSON.
      # system.defaults cannot represent Data, so write this whole key separately.
      system.activationScripts.userDefaults.text = lib.mkAfter ''
        closeupOverlayData="$(printf '%s' ${lib.escapeShellArg (builtins.toJSON overlaySettings)} | /usr/bin/xxd -p | /usr/bin/tr -d '\n')"
        launchctl asuser "$(id -u -- ${user})" sudo --user=${user} -- \
          /usr/bin/defaults write com.oomol.CloseUp overlaySettings -data "$closeupOverlayData"
      '';
    };
}
