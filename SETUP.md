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
