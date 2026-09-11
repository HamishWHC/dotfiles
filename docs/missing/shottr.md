# Shottr: shortcuts, macOS screenshot bindings and SOPS license

Status: Open. Priority: High. Dependencies: Owner-provided purchased license key; code/settings work can proceed before the key is available.

## Current state

Shottr is installed from Nix through [macos-necessities/default.nix](../../modules/features/applications/macos-necessities/default.nix). Local preferences include capture/OCR shortcuts, save/copy behaviour, scaling, output format and other options. The owner has bought a license key and wants SOPS-based management.

## Work

- Create a dedicated Shottr feature owning package inclusion, selected preferences, shortcuts and license provisioning.
- Import chosen local keybindings as the primary configuration, with output/copy/save preferences as appropriate. Inspect the current `cc.ffitch.shottr` sandbox preference format. Do not copy upload tokens, Keychain blobs or the whole plist into Nix.
- Disable native macOS screenshot shortcuts **only when the Shottr feature is included in the system**. Inspect the actual symbolic-hotkey IDs and representations for the installed macOS version; cover conflicting capture-to-file, capture-to-clipboard and screenshot-UI bindings as appropriate.
- Modify only the relevant entries in `com.apple.symbolichotkeys`, preserving every unrelated shortcut. Establish how managed entries are restored/released when Shottr is removed, including existing user choices; omission of a `defaults` write alone does not restore a previous value.
- Store the purchased key at the proposed `licenses/shottr/key` path in `secrets/default.yaml`. Follow the [secret contract](README.md#license-and-secret-contract).
- Find the supported license activation/import path. Prefer automatic activation using the runtime secret, and make it repeat-safe. If activation requires UI or a device-bound Keychain operation, provide secure provisioning plus the exact remaining manual step; a paid key and an upload token are different artifacts.

## Acceptance

- Declared Shottr keybindings work after a human grants required permissions.
- With Shottr included, native bindings do not intercept the same shortcuts. Without it, this feature does not disable native screenshots; removal/restoration behaviour is documented.
- License data never enters plaintext tracked files, the Nix store or logs. Repeated activation does not reset the license or repeatedly register a device.
- Capture, Screen Recording/Accessibility prompts, activation and feature-removal checks are listed in `SETUP.md` for the human.
- Run both Home Manager and Darwin builds using only the [allowed recipes](README.md#validation), covering enabled/disabled behaviour through suitable build configurations. Never switch the system.

References: [Shottr FAQ](https://shottr.cc/), [license purchase/activation information](https://shottr.cc/purchase.html).
