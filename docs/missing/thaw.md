# Thaw: portable behaviour with local hidden-app choices

Status: Portable preferences implemented; human activation/persistence verification remains. Updated 2026-10-22. Priority: High.

## Current state

The focused [thaw.nix](../../modules/features/applications/macos-necessities/thaw.nix) owns the Nix package and a narrow set of portable behaviour preferences through nix-darwin's `system.defaults.CustomUserPreferences`. The preference domain is `com.stonerl.Thaw`.

The owner explicitly wants the choice of visible/hidden/always-hidden applications to remain local.

## Work

### Assessment, 2026-10-22

- Installed version: 1.2.0. Its [general settings model](https://github.com/thaw-app/Thaw/blob/1.2.0/Thaw/Settings/Models/GeneralSettings.swift) reads and writes individual UserDefaults keys. Reveal triggers, rehide behaviour and selected appearance values can be owned independently of app membership/order.
- Local values: click, double-click and scroll reveal enabled; hover reveal disabled; auto-rehide enabled; `RehideStrategy = 0` means Smart. The stored `RehideInterval = 15` applies to Timed mode, not the currently selected Smart mode. The always-hidden section and hiding application menus are enabled.
- All six current hotkey entries contain JSON `null`: there are no assigned Thaw hotkeys to migrate. The [hotkey model](https://github.com/thaw-app/Thaw/blob/1.2.0/Thaw/Settings/Models/HotkeysSettings.swift) stores a dictionary whose values are JSON encoded as plist **data**, not plain strings. Any future hotkey management must preserve that type and merge only owned entries.
- [Per-display settings](https://github.com/thaw-app/Thaw/blob/1.2.0/Thaw/Settings/Models/DisplayIceBarConfiguration.swift) contain display-specific Ice Bar enablement/location and `alwaysShowHiddenItems`, keyed by display UUID. They do not contain the app membership list, but are still local display state and should remain unmanaged. The old global `UseIceBar` keys alone do not reproduce per-display behaviour.
- Keep `MenuBarItemManager.*`, display settings, status-item positions and migration flags outside the managed allowlist. Launch-at-login uses the app's registration UI and is separate from portable UserDefaults.
- This is source/read-only preference inspection, not a live persistence test. Use selected-key activation writes; do not replace the whole preference domain.

### Implementation boundaries

- Managed values cover reveal triggers, Smart rehide, timing, section controls, item spacing, tooltips and diagnostics. Nix generates individual top-level preference writes; omitted and subsequently removed keys retain their existing values.
- Hotkeys remain local (none were assigned). Custom icons, the serialized appearance configuration and per-display settings remain local as well.
- App membership/order, `MenuBarItemManager.*`, pending relocation/return destinations, `DisplayIceBarConfigurations`, status-item positions and migration flags are excluded.
- Do not replace the full plist, whole layout/profile objects, sandbox state or migration flags. An apparently visual setting may contain per-display app layout state; inspect before managing it.
- If Thaw cannot separate particular settings from local layout state, leave those settings local and explain the limitation. Do not compromise the owner's boundary to achieve full declarative coverage.

## Acceptance

- Portable preferences are documented and managed through a narrow allowlist.
- A human can change which apps are hidden/always-hidden, switch again, and retain those choices.
- No managed output serializes the local app membership/order.
- Record any unsupported setting and permissions in `SETUP.md`.
- Validate builds according to [README.md](README.md#validation); persistence checks require human activation.

Starting point: [Thaw upstream](https://github.com/thaw-app/Thaw), especially preference serialization and menu-bar layout storage for the packaged version.

## Validation, 2026-10-22

`just build-system personal`, `just build-system atlassian`, `just build-home personal hamishwhc` and `just build-home atlassian hcox` passed. No switch or app launch was performed. Human activation/restart is needed to load settings and confirm that local app placement remains intact.
