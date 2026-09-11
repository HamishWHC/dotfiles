# Codex: native options and shared AI configuration adapter

Status: Open. Priority: High. Dependency: [Shared AI option contract](ai-shared.md).

## Current state

Codex is installed through [ai.nix](../../modules/features/applications/ai.nix). The audited `~/.codex/config.toml` contains model/reasoning preferences and per-project trust entries; the repo does not manage those settings or custom reusable assets.

## Work

- Implement a focused Codex adapter (suggested `modules/features/applications/ai/codex.nix`) consuming the shared server/skill/instruction options.
- Expose portable native preferences such as model/reasoning choices through client settings. Do not hard-code a model from this audit; inspect the current supported options and owner's preferences.
- Render shared MCP definitions into the supported Codex schema, with correct transport mapping, executable paths and runtime secret handling. Preserve OAuth/authentication storage locally.
- Install owned skills into a user discovery location supported by the packaged Codex version. Verify current skill paths and symlink support rather than assume a historic `~/.codex/skills` path is universal. Preserve installed plugin/system skills and locally managed directories.
- Provide shared/global instructions without overwriting repository `AGENTS.md` files or flattening project precedence.
- Choose supported include/profile functionality or a narrow merge for mutable native configuration. Preserve project trust decisions, app-managed configuration and login state. Do not replace the entire `~/.codex` directory.
- Preserve client-specific approval/sandbox behaviour; replication of an MCP server does not imply authorization to use it.

## Acceptance

- Shared MCP servers and skills are discoverable by Codex with documented native mappings.
- Client-specific preferences and overrides behave according to the common contract.
- Removing a managed entry removes only that entry, leaving local/plugin state and authentication intact.
- Generated configurations and logs contain no plaintext secrets sourced during Nix evaluation/build.
- Add login, MCP authorization and any unsupported configuration step to `SETUP.md`.
- Build using the [allowed recipes](README.md#validation); the human verifies client discovery after switching.

References: [Codex config basics](https://developers.openai.com/codex/config-basic/), [MCP](https://developers.openai.com/codex/mcp/), [skills](https://developers.openai.com/codex/skills/). Use the OpenAI Docs skill when implementing this client.
