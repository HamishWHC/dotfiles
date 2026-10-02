# Mission Control Plus: replaced by CloseUp

Status: Superseded by owner decision. Do not implement Mission Control Plus licensing.

[closeup.nix](../../modules/features/applications/macos-necessities/closeup.nix) installs `oomol-lab/tap/closeup` from the pinned OOMOL Homebrew tap. The Mission Control Plus cask, license secret declarations and activation delay have been removed.

CloseUp's enabled state, hidden menu bar icon, stable update channel, disabled automatic update checks and eight Mission Control shortcuts are managed through `system.defaults.CustomUserPreferences`. The overlay shows only the close button. Its settings are JSON stored as plist Data, which the pinned `system.defaults` cannot encode; a small user-context activation hook writes the whole `overlaySettings` value through `defaults`.

Unrelated preferences, shortcut seeding state and updater/window state remain local. Removing a declared preference leaves its existing value unmanaged; by owner decision, `overlaySettings` is managed as a single value rather than individual fields. `SETUP.md` lists its manual permission and launch-at-login setup. CloseUp reads these preferences at launch, so an already-running instance needs to be relaunched after switching.

Validated the preferences change with `just build-system personal` and `just build-system atlassian`; both passed. No system switch or live app reload was performed.
