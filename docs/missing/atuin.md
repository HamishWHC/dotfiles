# Atuin: declare portable history UI preferences

Status: Open. Priority: Normal. Dependencies: None.

## Current state

[atuin.nix](../../modules/features/cli/atuin.nix) installs Atuin and initializes Zsh but does not manage its configuration. The audited `~/.config/atuin/config.toml` has `enter_accept = true` and a sync setting. History and login state are local.

## Work

- Use the pinned Home Manager Atuin module or a focused config file for selected portable settings.
- Preserve the owner's Enter behaviour, then capture chosen search/filter mode, appearance and sync preferences from the current file. Do not invent preferences for settings currently left at defaults.
- If switching to Home Manager's shell integration, remove duplicate manual initialization so Atuin is initialized once.
- Keep history databases, session IDs, account tokens and sync encryption keys outside ordinary Nix-managed configuration. Document login and history import only where needed.

## Acceptance

- A fresh setup receives the intended portable settings and one Zsh initialization path.
- Existing history and account state survive adoption and repeated activation.
- Remaining login/import steps are documented in `SETUP.md`.
- Use `just build-home` under the [backlog validation rules](README.md#validation), with no switch.

Starting point: [Atuin configuration](https://docs.atuin.sh/configuration/config/), plus the pinned Home Manager module.
