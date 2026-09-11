# Aptakube: SOPS-managed license only

Status: Open. Priority: High. Dependencies: Owner-provided entitlement material; implementation can start before it is supplied.

## Current state

[aptakube.nix](../../modules/features/applications/aptakube.nix) installs the application. The audited Mac has `~/Library/Application Support/com.aptakube.Aptakube/license.bin` and a separate `preferences.json`. The file's presence does not establish entitlement validity or transferability.

The owner explicitly excludes Aptakube preferences and cluster configuration. This ticket is license-only.

## Work

- Determine the installed version's supported license activation/import interface and whether the existing binary file is portable or device-bound. Record the actual entitlement type; do not assume the current subscription offerings describe an older purchase.
- Store the original key or supported transferable file in `secrets/default.yaml` at `licenses/aptakube/key` or `licenses/aptakube/file`. Choose and document one authoritative format rather than create redundant copies.
- Implement runtime provisioning and supported automatic activation/import with user ownership and restrictive permissions, following the [shared secret contract](README.md#license-and-secret-contract).
- Handle absent secrets on hosts that do not use the license, refresh/renewal, app-owned file writes and repeated activation. Do not use an immutable symlink where the application rewrites its license file.
- If there is no supported unattended activation path, retain automatic secret delivery and document the exact manual activation operation and reason it is still required.

## Acceptance

- A provisioned entitlement can be restored on an eligible Mac using the implemented mechanism, without plaintext license data in Nix outputs or logs.
- Repeated activation does not consume another device slot or overwrite a refreshed license with stale state.
- `preferences.json`, kubeconfigs, cluster selection and all other Aptakube settings remain local.
- `SETUP.md` records secret onboarding and any remaining device activation/deactivation steps.
- Run relevant [home/system builds](README.md#validation); real activation is human-verified after a switch.

References: [license management](https://aptakube.com/license-manager), [current license offerings](https://aptakube.com/pricing).
