# Paseo: options and reuse of managed Codex/Claude configuration

Status: Open. Priority: High. Dependencies: [Shared AI contract](ai-shared.md); [Codex](codex.md) and [Claude Code](claude-code.md) for complete integration.

## Current state

Paseo is installed as a cask in [ai.nix](../../modules/features/applications/ai.nix). The audited Mac has `~/Library/Application Support/Paseo/desktop-settings.json`. No desktop or daemon configuration is managed.

Paseo desktop preferences, daemon configuration and configuration of the agents it launches are separate layers. Confirm the packaged version and deployment mode before choosing paths.

## Work

- Add a focused Paseo adapter (suggested `modules/features/applications/ai/paseo.nix`) with appropriate desktop/daemon options.
- Manage selected portable preferences and intended startup/connection behaviour through supported interfaces. Preserve pairing credentials, device identities, session records and application databases.
- Ensure GUI/daemon-launched Codex and Claude can find the managed executable packages, home/config environment, shared MCP servers and skills. Do not depend solely on interactive Zsh's PATH.
- Reuse each client's managed configuration; do not write a second competing copy of Codex or Claude settings from Paseo.
- Distinguish Paseo exposing its own MCP service, injecting its tools into agents, and external MCP servers used by those agents. Expose these independently where supported; adding shared client servers must not implicitly enable a remotely reachable Paseo service.
- Keep provider-specific functionality explicit and document features that cannot be replicated across the launched agents.

## Acceptance

- Chosen Paseo options are reproducible and retain local pairing/session state.
- Agents launched through Paseo use the same intended MCP/skill configuration as direct launches.
- Startup/connection configuration does not overwrite local trust or enable unintended network exposure.
- `SETUP.md` describes pairing, login and any first-launch desktop operations that remain manual.
- Run applicable [home/system builds](README.md#validation); do not start a daemon or pair devices as a substitute for a human post-switch check.

References: [Paseo configuration](https://paseo.sh/docs/configuration), [Paseo MCP reference](https://paseo.sh/docs/mcp). The documented daemon config is not automatically the same file as Electron desktop preferences.
