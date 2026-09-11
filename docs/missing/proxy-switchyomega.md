# Proxy SwitchyOmega: portable proxy profiles

Status: Open. Priority: High. Dependency: [Firefox profile integration](firefox.md). Coordinate optional Chromium support with [its ticket](ungoogled-chromium.md).

## Current state

Firefox has the `switchyomega@feliscatus.addons.mozilla.org` extension installed locally. Neither extension installation nor its proxy profiles/rules are represented in the repo. Firefox's ticket owns installation; this ticket owns the extension's configuration.

## Work

- Inspect the installed extension/version and supported configuration backup/import, sync, or managed-storage interfaces. Prefer a portable export over copying browser storage databases.
- Represent intended proxy endpoints, bypass rules, profile names, automatic-switch rules and any rule-list source. A reusable local Burp proxy profile is useful; take its actual endpoint from the Burp configuration rather than assuming a port.
- Preserve the currently selected profile as local runtime state unless the owner chooses a fixed default.
- Keep passwords/tokens in SOPS when required; avoid leaking private work routing rules into public configuration. Provide host-specific inputs where necessary.
- Determine whether the settings can be applied automatically without resetting unrelated extension state. Do not assume arbitrary `storage.local` databases are declarative configuration files.
- Add Chromium support only for a verified compatible installed extension/version. Do not silently replace SwitchyOmega with a fork or unrelated proxy extension.

## Acceptance

- Portable profiles/rules are represented and the supported import path is documented.
- Automatic provisioning is implemented if the installed extension supports it. If not, provide the export artifact and exact manual import instructions, explicitly recording the limitation.
- Reapplying settings preserves unrelated extension data and does not force a proxy for every browser session.
- Document any dependency on Burp being started and on its CA trust setup.
- Build through the commands in [README.md](README.md#validation); extension import and proxy checks are human post-switch steps.

Starting point: [SwitchyOmega upstream](https://github.com/FelisCatus/SwitchyOmega), plus the installed extension's options/export format.
