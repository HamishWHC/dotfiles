# Thaw: portable behaviour with local hidden-app choices

Status: Open. Priority: High. Dependencies: None; coordinate macOS utility imports.

## Current state

Thaw is installed from Nix. Local `com.stonerl.Thaw` preferences mix portable behaviour with menu-bar item identities, saved section order, display configurations, pending relocations and migration flags.

The owner explicitly wants the choice of visible/hidden/always-hidden applications to remain local.

## Work

- Extract a focused feature and define an allowlist of portable preferences such as reveal triggers, rehide timing, general appearance and hotkeys.
- Determine whether selected keys can be updated independently of the app-owned state, using supported settings or selective defaults writes.
- Exclude app membership/order and all data encoding hidden/always-hidden choices. Candidate state keys observed locally include `MenuBarItemManager.savedSectionOrder`, `MenuBarItemManager.knownItemIdentifiers`, pending relocation/return destinations and `DisplayIceBarConfigurations`; inspect current source/schema rather than relying on these names alone.
- Do not replace the full plist, whole layout/profile objects, sandbox state or migration flags. An apparently visual setting may contain per-display app layout state; inspect before managing it.
- If Thaw cannot separate particular settings from local layout state, leave those settings local and explain the limitation. Do not compromise the owner's boundary to achieve full declarative coverage.

## Acceptance

- Portable preferences are documented and managed through a narrow allowlist.
- A human can change which apps are hidden/always-hidden, switch again, and retain those choices.
- No managed output serializes the local app membership/order.
- Record any unsupported setting and permissions in `SETUP.md`.
- Validate builds according to [README.md](README.md#validation); persistence checks require human activation.

Starting point: [Thaw upstream](https://github.com/thaw-app/Thaw), especially preference serialization and menu-bar layout storage for the packaged version.
