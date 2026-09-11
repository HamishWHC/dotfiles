# First-time setup

## Before activation

1. Install Nix if needed and clone this repository.
2. Sign into the Mac App Store with the account that owns your apps. Install and sign into 1Password if used.
3. Set up this Mac's secrets access using the [new-device instructions](README.md#adding-a-new-device).

## After activation

1. Open Rectangle, Mac Mouse Fix, Thaw and Shottr; grant their requested Accessibility/Screen Recording permissions and enable launch at login where wanted.
2. Activate Shottr, Aptakube and Mission Control Plus with your licenses. Activate Mac Mouse Fix if prompted.
3. Configure Rectangle shortcuts, Thaw's hidden apps and Shottr keybindings. Disable conflicting native shortcuts in **System Settings → Keyboard → Keyboard Shortcuts → Screenshots**.
4. Configure Firefox/Chromium, install your extensions and sign into browser services. Configure Velja and select it as the default browser.
5. Open and configure OrbStack using the **Free** edition; complete its initial setup.
6. Sign into and configure Codex and Claude Code, including MCP servers and skills. Set up and pair Paseo.
7. Restore SSH keys and local Git/SSH configuration. Create the directory required by SSH: `mkdir -p ~/.ssh/sockets && chmod 700 ~/.ssh/sockets`.
8. Configure AWS credentials/SSO and local Kubernetes access. Select a Rust toolchain with `rustup default <toolchain>`.
9. Configure Atuin and sign in if using history sync.
10. Configure VS Code/VSCodium and install your preferred editor fonts.
11. If using Burp with an external browser, import and trust its CA certificate in Keychain and the browser as needed; configure SwitchyOmega proxy profiles.
12. Sign into and configure other apps you use, including Word/Excel. On the work Mac, complete Okta Verify, ACLI/KITT and MeetingBar setup.

## macOS system preferences

The desktop profile includes `macos-preferences` on both macOS hosts. It manages
typing, Australian English and keyboard layout, appearance, Dock/Spaces, native
window tiling, Finder, selected trackpad gestures, the menu-bar clock, Option-scroll
zoom, and the native screenshot destination (`~/Desktop/Screen Captures`, created
automatically). It does not manage Spotlight or screenshot shortcuts; those belong
to the Raycast and Shottr features. App preferences and the tickets in `docs/missing`
remain separate.

After a human performs a system switch, log out and back in if applications still
show cached preferences. Check typing/repeat, Finder list view/current-folder
search, Dock hiding and stable Spaces order, disabled edge tiling, trackpad clicks
and App Exposé, the clock, Option-scroll zoom, and the native screenshot destination.
Check that Australian is selected under Keyboard → Text Input; additional enabled
layouts and macOS input methods are preserved.

Caps Lock maps to Fn/Globe for keyboard vendor/product/interface tuples
`1133-50503-0`, `1452-834-0`, and `3141-25903-0`. Other modifier mappings are preserved.
After logging in, verify the remap also survives reconnecting the keyboard. A new
keyboard model needs its tuple added to `input-preferences.py` or a local mapping
in System Settings → Keyboard → Keyboard Shortcuts → Modifier Keys.

Managed values are reapplied on activation. To release a setting, remove its
declaration (and its host-specific mirror for trackpad gestures), then change it in
System Settings after the next human-performed switch. Removing the feature stops
writes but retains the last applied values; it does not restore an old snapshot,
delete the screenshot directory, or reset unrelated local preferences. Builds do
not verify GUI behavior or accessibility permissions; verify Option-scroll zoom
in System Settings → Accessibility → Zoom if macOS rejects that preference write.
