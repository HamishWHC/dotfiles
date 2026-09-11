# Ungoogled Chromium: portable browser setup

Status: Open. Priority: Normal. Dependencies: None; coordinate edits to [browsers.nix](../../modules/features/applications/browsers.nix).

## Current state

The macOS cask is installed, with no managed preferences, profile setup or extension-installation process. The audit did not inventory this browser's live settings; do not copy Firefox assumptions into it.

## Work

- Inventory selected local preferences, search engines and installed extensions before choosing what to manage.
- Determine which policy/preferences mechanisms the actual ungoogled Chromium build supports on macOS. Its extension distribution differs from ordinary Google Chrome; document the supported install/update process.
- Add a focused feature using portable settings and a non-destructive profile migration strategy.
- Coordinate SwitchyOmega integration through [its ticket](proxy-switchyomega.md); it owns the proxy configuration artifact.
- Preserve bookmarks, history, cookies, sessions, account data and local proxy selection. Do not manage the entire mutable `Preferences` or `Local State` file as an immutable symlink.

## Acceptance

- Selected preferences and a supported extension setup process are reproducible and documented.
- The cask remains the macOS installation source unless a concrete packaging issue requires a justified change.
- Repeated activation preserves local profile state; any unavoidable manual import is in `SETUP.md`.
- Use the applicable builds in [README.md](README.md#validation); no system switch.

Starting point: [ungoogled-chromium documentation](https://github.com/ungoogled-software/ungoogled-chromium#readme).
