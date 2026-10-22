# Shottr: shortcuts, macOS screenshot bindings and SOPS license

Status: Partially implemented: package and encrypted key exist; settings and runtime license setup remain open. Reassessed from source on 2026-10-22. Priority: High. Dependencies: The encrypted key is already supplied.

## Current state

Shottr is installed from Nix through [macos-necessities/default.nix](../../modules/features/applications/macos-necessities/default.nix). Local preferences include capture/OCR shortcuts, save/copy behaviour, scaling, output format and other options. The owner has bought a license key and wants SOPS-based management.

`secrets/default.yaml` already contains an encrypted `shottr_license_key`. No Shottr runtime secret declaration, settings management or license activation code was found. [macos.nix](../../modules/features/desktop/macos.nix) explicitly enables native screenshot shortcuts 28–31 and 184, so conditional conflict handling is still missing. No secret was decrypted, and no new builds or live activation checks were performed for this assessment.

## Work

- Create a dedicated Shottr feature owning package inclusion, selected preferences, shortcuts and license provisioning.
- Import chosen local keybindings as the primary configuration, with output/copy/save preferences as appropriate. Inspect the current `cc.ffitch.shottr` sandbox preference format. Do not copy upload tokens, Keychain blobs or the whole plist into Nix.
- Disable native macOS screenshot shortcuts **only when the Shottr feature is included in the system**. Inspect the actual symbolic-hotkey IDs and representations for the installed macOS version; cover conflicting capture-to-file, capture-to-clipboard and screenshot-UI bindings as appropriate.
- Modify only the relevant entries in `com.apple.symbolichotkeys`, preserving every unrelated shortcut. Follow [AGENTS.md](../../AGENTS.md) when ownership ends: removing a setting from Nix must preserve its existing value, not reset it. Reconcile the existing generic macOS shortcut declarations with Shottr's conditional ownership.
- Reuse the existing encrypted `shottr_license_key` in `secrets/default.yaml`; no additional purchased key or duplicate secret path is needed. Add runtime provisioning under the [secret contract](README.md#license-and-secret-contract).
- Find the supported license activation/import path. Prefer automatic activation using the runtime secret, and make it repeat-safe. If activation requires UI or a device-bound Keychain operation, provide secure provisioning plus the exact remaining manual step; a paid key and an upload token are different artifacts.

## Acceptance

- Declared Shottr keybindings work after a human grants required permissions.
- With Shottr included, native bindings do not intercept the same shortcuts. Without it, this feature does not write native screenshot settings; removing a managed setting preserves its existing value.
- License data never enters plaintext tracked files, the Nix store or logs. Repeated activation does not reset the license or repeatedly register a device.
- Necessary manual permission and license operations are documented in `SETUP.md`. Capture and feature-removal verification belongs in this ticket, not `SETUP.md`.
- Run both Home Manager and Darwin builds using only the [allowed recipes](README.md#validation), covering enabled/disabled behaviour through suitable build configurations. Never switch the system.

References: [Shottr FAQ](https://shottr.cc/), [license purchase/activation information](https://shottr.cc/purchase.html).
