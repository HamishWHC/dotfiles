# Velja: browser routing preferences

Status: Open. Priority: Normal. Dependencies: None; coordinate browser aggregate changes with Firefox/Chromium tickets.

## Current state

[browsers.nix](../../modules/features/applications/browsers.nix) installs Velja through the App Store. Local preferences include default/alternative browsers, preferred browsers, tracking-parameter behaviour and `rulesBackup`.

## Work

- Capture the intended browser routing rules and portable preferences using supported export/import or selective preference management.
- Inspect the actual rules representation; do not assume `rulesBackup` is the authoritative live rule database.
- Parameterize profile identifiers/paths where needed and document how to reconnect browsers on a new Mac.
- Preserve sandbox bookmarks, runtime logs and local account state. App Store purchase/account restoration remains local.
- Document default-browser selection and launch-at-login steps where macOS requires user interaction.

## Acceptance

- Desired default/alternative browser and routing behaviour are represented without overwriting the whole sandbox preference store.
- Existing browser identities are reconciled rather than replaced with machine-specific paths from the audited Mac.
- Any unsupported automation is described as an exact manual import/setup step.
- Validate with applicable `just build-home` / `just build-system` checks; leave routing checks after switching to the human.

Starting point: [Velja's documentation and scripting support](https://sindresorhus.com/velja).
