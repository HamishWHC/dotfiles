# Rectangle: settings and persistent Accessibility authorization

Status: Open. Priority: High. Dependencies: None; coordinate imports in [macos-necessities/default.nix](../../modules/features/applications/macos-necessities/default.nix).

## Current state

Rectangle is installed from Nix without managed preferences. Local settings include shortcuts, gaps, menu-bar visibility and launch-on-login. The owner reports having to re-grant Accessibility permission after every system switch.

## Work

- Extract Rectangle into a focused feature and manage the chosen shortcuts, gap sizes, repeated-command behaviour and launch/menu-bar settings.
- Use supported JSON import or selective defaults. Rectangle can consume `~/Library/Application Support/Rectangle/RectangleConfig.json` at launch and rename it afterward; account for this mutable import lifecycle instead of symlinking blindly.
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
