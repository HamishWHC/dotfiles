# Mission Control Plus: SOPS-managed license

Status: Open. Priority: Normal. Dependencies: Owner-provided license material.

## Current state

[macos-necessities/default.nix](../../modules/features/applications/macos-necessities/default.nix) installs Mission Control Plus. The app is paid and has a trial. Local preferences include purchase-related state, but this audit did not establish a portable key or valid entitlement.

Preferences, launch behaviour and shortcuts remain locally managed under the owner's macOS utility exclusion. Only license handling is in scope.

## Work

- Identify the supported activation or restoration mechanism for the installed version, including any device-bound purchase state.
- Store usable license material under `licenses/mission_control_plus/key` or `licenses/mission_control_plus/file` in `secrets/default.yaml`.
- Provision it at runtime and automate supported activation/import, following the [SOPS contract](README.md#license-and-secret-contract).
- Preserve unrelated preferences and app-owned purchase state. Do not treat cached flags or analytics identifiers as license keys.
- If only interactive activation is supported, implement secure delivery and add precise UI restoration instructions and the limitation to `SETUP.md`.

## Acceptance

- License restoration has a concrete implementation and documented input format.
- Missing secrets, repeat activation and app-owned mutation are handled without exposing keys or repeatedly registering devices.
- No ordinary Mission Control Plus configuration is added.
- Validation uses the [allowed builds](README.md#validation); purchase/activation UI and system switching remain human tasks.

Reference: [Mission Control Plus](https://www.fadel.io/missioncontrolplus).
