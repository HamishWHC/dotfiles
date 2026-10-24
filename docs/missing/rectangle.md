# Rectangle: settings and persistent Accessibility authorization

Status: Preferences implemented; human activation and permission persistence remain unverified. Updated 2026-10-22. Priority: High.

## Current state

The focused [rectangle.nix](../../modules/features/applications/macos-necessities/rectangle.nix) owns the existing Homebrew cask and portable preferences through `system.defaults.CustomUserPreferences`. Commit `3d6a201` moved it from Nix packaging to address repeated permission problems. Do not redo that migration without evidence of a current issue.

Managed values include the Magnet shortcut preset, three explicit shortcut overrides, gaps, repeated-command behaviour, snap-area settings, preview/drag behaviour, menu-bar visibility and launch-on-login preference. Updater state and welcome/migration flags remain local. The implementation uses individual top-level defaults writes, preserving unrelated keys and removed declarations. It does not use Rectangle's JSON importer.

## Work

### Assessment, 2026-10-22

- Installed version: 2.0.3. Local selected values are `gapSize = 10`, `hideMenubarIcon = true`, `launchOnLogin = true`, `alternateDefaultShortcuts = true` (Magnet defaults), and `subsequentExecutionMode = 1` (repeat left/right moves to an adjacent display). The explicit `almostMaximize` shortcut has `keyCode = 42`, `modifierFlags = 786432`.
- [Upstream documents selective defaults writes](https://github.com/rxhanson/Rectangle/blob/v2.0.3/TerminalCommands.md), including shortcuts. Use narrowly owned keys and preserve other preferences; app restart is required for these settings.
- The [2.0.3 JSON importer](https://github.com/rxhanson/Rectangle/blob/v2.0.3/Rectangle/SettingsWindow/Config.swift) removes existing action shortcuts omitted from the imported file. Its launch-time import also asks for confirmation, refuses symlinks/world-writable files, and renames or removes the import afterward. A partial immutable Home Manager JSON file is therefore unsuitable for preserving unrelated shortcuts.
- [Startup code](https://github.com/rxhanson/Rectangle/blob/v2.0.3/Rectangle/AppDelegate.swift) attempts login-item registration when `launchOnLogin` is enabled. A preference write is not itself proof that macOS has accepted registration or Accessibility permission.
- Preference management is implemented. Keep the Homebrew installation; no evidence in this pass justifies another packaging migration. Permission persistence still requires human activation.

### Remaining implementation

- After the human activates the configuration, restart Rectangle to load its settings. There is no live setting or permission verification from a build alone.
- Investigate the grant-reset cause: application launch path, bundle identifier, signing identity/designated requirement, and whether Home Manager copying or Nix packaging changes the app identity. A stable path alone is not proof of stable TCC identity.
- Prefer preserving upstream signing and a stable installed application identity. Keep a single intended app installation and ensure launch/login registration points to it.
- Assess supported automatic Accessibility authorization for the installed macOS version and host management environment. Apple's PPPC mechanism is device-management functionality; do not promise a local `defaults` write or locally installed profile can grant it.
- If MDM is needed, document the precise administrator-provided policy/code requirement. On an unmanaged Mac, provide the remaining one-time manual grant and fix repeat-grant behaviour as far as supported.
- Do not manipulate the TCC database directly, disable SIP, or repeatedly reset privacy permissions.

## Acceptance

- Selected Rectangle preferences are reproducible and local unrelated preferences are preserved.
- The implementation records evidence for the app-identity diagnosis and chosen installation strategy.
- Either grants survive a human-performed repeat switch, or the remaining platform limitation and reproducible cause are documented. Do not report this as verified from a build alone.
- `SETUP.md` distinguishes automatic management, one-time user consent, and any MDM-only path.
- Run applicable builds from [README.md](README.md#validation). The human performs both switches needed to assess persistence.

References: [Rectangle configuration](https://github.com/rxhanson/Rectangle#import--export-json-config), [Apple PPPC deployment](https://support.apple.com/guide/deployment/privacy-preferences-policy-control-payload-dep38df53c2a/web).

## Validation, 2026-10-22

`just build-system personal` and `just build-system atlassian` passed. Both corresponding `just build-home` checks passed as well. No switch, app launch or live permission change was performed. After human activation, Rectangle must be restarted to load preferences; Accessibility persistence remains a human runtime check.
