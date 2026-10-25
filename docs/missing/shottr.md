# Shottr: shortcuts, macOS screenshot bindings and SOPS license

Status: Implemented and build-validated for both macOS hosts on 2026-10-25; awaiting human activation. Priority: High.

## Implementation

[shottr/default.nix](../../modules/features/applications/macos-necessities/shottr/default.nix) owns the package, selected preferences, the runtime `shottr_license_key` secret and the native shortcut override. [setup.py](../../modules/features/applications/macos-necessities/shottr/setup.py) runs after `copyApps` and `sops-nix`; its synthetic tests run at build time.

- Preferences: capture/OCR shortcuts (Command-Shift-1 to 4) and scrolling capture (Control-Command-Shift-4, `KeyboardShortcuts_scrolling`, name found in the binary), copy and show after capture without saving, copy on Escape, `Auto` format and no downscaling. The save folder (`defaultFolder` plus a security-scoped bookmark), upload settings, telemetry and UI state stay local.
- Shottr is sandboxed: `defaults <bundle id>` does not reach its preferences. The script writes the container domain by path through `defaults`, writing only differing keys. Shottr reads hotkeys at launch, so a running Shottr is quit before writes and relaunched afterwards.
- License: Shottr 1.9.2's URL handler accepts the undocumented `shottr://settings/license=<KEY>` (found by disassembly). It strips the key to `[A-Z0-9-]`, uppercases it, fills the License field and runs the Activate handler, which verifies online. The URL is passed on stdin to `NSWorkspace`, so the key is never printed or put in process arguments. Deep links are enabled only during activation, then `allowDeeplinks` is restored to its previous value or absence.
- Activation status: a nonempty `kc-license` string. The owner confirmed on 2026-10-25 that it disappears when the license is removed, while `kc-vault` remains. Its value is never printed. Licensed hosts are skipped without reading the secret.
- Unreadable state: when macOS blocks container access, `defaults export` returns an empty domain with exit status 0. The script first opens the plist directly; a permission error skips setup with a warning rather than treating Shottr as unlicensed. A missing container launches Shottr hidden once and waits 15 seconds.
- Native shortcuts: with the feature included, every Screenshots shortcut is disabled with `lib.mkForce`, as Raycast does for Spotlight: 28–31 (save/copy full screen and area), 184 (toolbar) and 261 (Ask Siri about selected area, Command-Shift-6; ID read from System Settings on 2026-10-25). The owner does not need 261 at all, so it is only disabled, with no binding. Without Shottr, [macos.nix](../../modules/features/desktop/macos.nix) keeps its existing declarations.

## Validation

`just build-home personal hamishwhc`, `just build-home atlassian hcox`, `just build-system personal` and `just build-system atlassian` passed on 2026-10-25, and all four builds passed again after adding 29, 31, 184, 261 and the scrolling shortcut. The built system's `AppleSymbolicHotKeys` has 28–31, 184 and 261 disabled. No preferences were written, no deep link was opened and no system switch was performed.

## Remaining human verification

- After switching, confirm activation prints `Shottr: license activated.` and Shottr's License tab shows the registration. A timeout or a deep link permission prompt means the undocumented URL behaves differently than the disassembly suggested.
- Confirm Command-Shift-1 to 4 and Control-Command-Shift-4 trigger Shottr rather than the native screenshot tool, and that a repeated switch is silent and does not restart Shottr.
- If Shottr updates, recheck that the deep link and `kc-license` behaviour still hold; both are undocumented.
