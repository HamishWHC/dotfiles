{
  flake.features.velja.darwin = {
    homebrew.masApps."Velja" = 1607635845;

    # Canonical identifiers from Velja 3.2.4's preferredBrowsers array.
    # The user's current default browser, rules and profiles remain local.
    system.defaults.CustomUserPreferences."com.sindresorhus.Velja".preferredBrowsers = [
      "browser:org.mozilla.firefox"
      "browser:org.chromium.Chromium"
      "browser:com.apple.Safari"
      "privateBrowser:org.mozilla.firefox"
    ];
  };
}
