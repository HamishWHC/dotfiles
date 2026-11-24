# First-time setup

## Before activation

1. Install Nix if needed and clone this repository.
2. Sign into the Mac App Store with the account that owns your apps. Install and sign into 1Password if used.
3. Set up this Mac's secrets access using the [new-device instructions](README.md#adding-a-new-device).

## After activation

1. If macOS asked whether your terminal may access data from other apps during activation and you declined, allow it in **System Settings → Privacy & Security** and activate again; Shottr's settings and license need it.
2. Open Mac Mouse Fix, CloseUp, Thaw and Shottr; grant their requested Accessibility/Screen Recording permissions and enable launch at login where wanted.
3. Grant Rift Accessibility and Screen Recording access in **System Settings → Privacy & Security**, then run `rift service restart`.
4. For side-by-side monitors, arrange them diagonally in **System Settings → Displays → Arrange**: the left monitor up and to the left, touching the right monitor only at a corner.
5. Configure Thaw's hidden apps.
6. Configure Firefox/Chromium, install your extensions and sign into browser services. Configure Velja and select it as the default browser.
7. Open and configure OrbStack using the **Free** edition; complete its initial setup.
8. Sign into and configure Codex and Claude Code, including MCP servers and skills. Install T3 Code from https://t3.codes/.
9. Restore SSH keys and local Git/SSH configuration.
10. Configure AWS and Kubernetes authentication as needed.
11. Configure Atuin and sign in if using history sync.
12. Configure VS Code/VSCodium and install your preferred editor fonts.
13. If using Burp with an external browser, import and trust its CA certificate in Keychain and the browser as needed.
14. Sign into and configure other apps you use, including Word/Excel. On the work Mac, complete Okta Verify, ACLI/KITT and MeetingBar setup.
