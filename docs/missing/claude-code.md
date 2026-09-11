# Claude Code: native options and shared AI configuration adapter

Status: Open. Priority: High. Dependency: [Shared AI option contract](ai-shared.md).

## Current state

Claude Code is installed through [ai.nix](../../modules/features/applications/ai.nix). The audited `~/.claude/settings.json` includes a theme preference. Shared MCP servers, instructions and skills are not managed by this repo.

## Work

- Implement a focused adapter (suggested `modules/features/applications/ai/claude-code.nix`) consuming the common MCP/skill/instruction definitions.
- Manage chosen portable user settings and expose native overrides rather than force Codex-specific concepts into Claude settings.
- Verify the correct user-scoped MCP storage and interface for the installed version. User MCP registration, `settings.json` and project `.mcp.json` are distinct concerns; do not assume writing `mcpServers` into `settings.json` configures user servers.
- Use supported configuration/registration or a narrow owned-entry merge. Preserve non-managed MCP servers and all unrelated mutable data, including any metadata stored in `~/.claude.json`.
- Install owned shared skills and global instruction content in supported Claude discovery locations, preserving local/plugin skills and project `CLAUDE.md` files.
- Map remote/stdio definitions and runtime secret references correctly. Leave account credentials and MCP OAuth grants local.
- Preserve native permission/hook semantics. If optional hooks are exposed, implement explicit Claude-specific options rather than blindly reuse an incompatible Codex schema.

## Acceptance

- One shared server/skill definition appears correctly in both Claude and the Codex adapter without duplicate declarations.
- Client-specific settings remain expressible; unsupported shared settings receive a clear diagnostic or documented exclusion.
- Repeated activation and managed-entry removal preserve unrelated settings and authenticated sessions.
- `SETUP.md` covers login, MCP authorization and any first-run approvals.
- Only use the relevant [build recipes](README.md#validation); live registration/authorization validation follows a human switch.

References: [Claude MCP scopes](https://code.claude.com/docs/en/mcp), [Claude settings](https://code.claude.com/docs/en/settings), [Claude skills](https://code.claude.com/docs/en/skills).
