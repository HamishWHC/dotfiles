# AI tools: shared MCP, skills and instruction options

Status: Open. Priority: High. Dependencies: None. Enables [Codex](codex.md), [Claude Code](claude-code.md) and [Paseo](paseo.md) adapter work.

## Current state and goal

[ai.nix](../../modules/features/applications/ai.nix) only installs Codex, Claude Code and Paseo. The owner wants a single set of Nix options for shared MCP servers, skills and related reusable configuration, replicated to Codex and Claude Code. Paseo should launch those tools with the same configuration and have its own appropriate options.

This ticket owns the common option contract and shared assets, not client-specific file generation. Keep the design proportionate to these tools.

## Proposed contract

Use a namespace such as `dotfiles.ai` and document the final names before adapter tickets merge. The initial shape should cover:

- Named MCP servers: enabled state; target clients (Codex/Claude); stdio command/package and arguments or remote URL/transport; non-secret environment/headers; runtime secret references; appropriate timeouts where portable.
- Named skills: source directory (including `SKILL.md` and supporting assets), enabled state and target clients. Reuse one source per skill and install only owned entries, preserving unrelated local/plugin skills.
- Shared instruction text/files with explicit client-specific additions. Preserve project-level instructions and client precedence.
- Per-client enablement, native extra settings and explicit overrides where semantics differ. Preserve normal user-controlled approval and sandbox defaults unless deliberately configured; do not equate different clients' permission vocabularies.

These are proposed repository options, not claims that all clients accept the same native schema. Make unsupported transports/settings explicit rather than silently ignoring them. Establish deterministic merge/override rules and reject structurally incompatible combinations through the Nix module interface.

## Work and ownership

- Prefer a new `modules/features/applications/ai/shared.nix` (or equivalent focused file). Keep additive imports in `ai.nix` small.
- Define the contract and supply minimal inert configuration examples for adapter authors. Do not add real servers or install new third-party skills just to demonstrate the schema.
- Decide how runtime secrets reach native config or server wrappers using the existing SOPS infrastructure. A secret must not become a Nix string value read during evaluation; authenticated remote MCP and stdio environment secrets both need a viable design.
- Declare ownership of generated file sections and managed skill entries so adapters can remove their own entries without deleting local state.
- Separate MCP configuration from OAuth authorization. Server registration is portable; account grants/tokens are not automatically reproduced by copying configuration.
- Document the cross-client mapping and unsupported capabilities in this ticket or an adjacent design document. Adapters own detailed native examples and final file paths.

## Acceptance

- One shared server/skill definition can be consumed by both adapters without duplicate input definitions.
- Client-specific exclusions/overrides are possible and their precedence is documented.
- Secret references, executable discovery from GUI-launched tools and mutable-state preservation have concrete contracts.
- Codex/Claude adapter authors can implement against stable option names independently. Paseo does not need to invent another source of truth.
- Use only relevant `just build-home` / `just build-system` builds per [README.md](README.md#validation); no live MCP connections or tool logins are required for this contract ticket.

References: [Codex MCP](https://developers.openai.com/codex/mcp/), [Claude Code MCP](https://code.claude.com/docs/en/mcp), [Paseo configuration](https://paseo.sh/docs/configuration). Recheck official documentation against installed versions during implementation.
