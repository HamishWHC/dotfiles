# Docker and OrbStack: runtime settings and CLI setup prompt

Status: Open. Priority: High. Dependencies: None. OrbStack edition: **Free**, per the owner.

## Current state

[docker.nix](../../modules/features/cli/docker.nix) installs OrbStack on macOS and removes its packaged `kubectl`, `docker`, `docker-buildx` and `docker-compose` entries in favour of separately managed clients. It does not manage OrbStack runtime settings.

The audited Docker config selects the `orbstack` context and `osxkeychain` credential helper. The owner wants runtime settings managed and, if possible, the CLI-install popup suppressed.

## Work

- Capture intended OrbStack runtime preferences: resource limits, relevant network/DNS/proxy settings and startup behaviour. Use supported configuration interfaces, inspecting the installed version's documented schema and local settings.
- Investigate the exact CLI-install prompt and detection path. Determine whether a supported preference suppresses it, or whether it reflects missing CLI links/tools despite the Nix packages being available in interactive shells.
- Preserve deliberate Nix ownership of Docker/buildx/compose/kubectl. Solve GUI discovery and required OrbStack tools without creating duplicate competing installations or automatically replacing the user's CLI layout.
- If the prompt has no supported suppression method, record the evidence and the least intrusive manual action in `SETUP.md`; do not invent an undocumented preference and claim success.
- Make Docker context/credential-helper setup repeatable where useful. Confirm the selected helper actually exists, and merge only managed keys instead of replacing `~/.docker/config.json` (which can contain registry authentication).
- Preserve containers, images, volumes, VMs, local Docker contexts and Kubernetes clusters. No cluster provisioning belongs in this ticket.
- No license secret, Pro activation, subscription recommendation or paid-feature dependency is to be added.

## Acceptance

- The chosen supported runtime settings are represented as host-aware options and applied without resetting runtime data.
- CLI popup suppression is implemented with evidence or explicitly documented as a remaining limitation.
- Nix-managed Docker clients/plugins and OrbStack's runtime can coexist; authentication state stays local.
- `SETUP.md` covers unavoidable first launch/helper installation and the Free-edition choice.
- Validate relevant [home/system builds](README.md#validation). Do not start/stop VMs or containers, install helpers on the live Mac, or switch to test this ticket.

References: [OrbStack settings](https://docs.orbstack.dev/settings), [upstream CLI-link issue](https://github.com/orbstack/orbstack/issues/1152) as investigation context, not proof of the current prompt's cause.
