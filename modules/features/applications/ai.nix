{
  flake.features.ai.homeManager =
    { lib, pkgs, ... }:
    {
      xdg.mimeApps.defaultApplications = lib.mkIf pkgs.stdenv.isLinux {
        "x-scheme-handler/t3code" = [ "com.t3tools.T3Code.desktop" ];
      };

      home.packages = [
        pkgs.unstable.claude-code
        pkgs.unstable.codex
      ]
      # On macOS, T3 Code is installed manually: the Nix-built Electron has no
      # NSAppleEventsUsageDescription, so macOS silently denies the Apple Events
      # that utmctl and osascript send to UTM.
      ++ lib.optional pkgs.stdenv.isLinux pkgs.unstable.t3code;
    };
}
