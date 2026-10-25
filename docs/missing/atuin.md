# Atuin: declare portable history UI preferences

Status: Implemented and build-validated for both macOS hosts on 2026-10-25; awaiting human activation. Priority: Normal.

## Implementation

[atuin.nix](../../modules/features/cli/atuin.nix) uses Home Manager's `programs.atuin`, which owns installation and the single Zsh initialization (the manual `eval` was removed).

- Settings: `enter_accept = true` and `sync.records = true`, the only non-default values in the audited `config.toml` (the rest was commented defaults). The owner chose no other preferences.
- `forceOverwriteSettings = true` replaces the existing unmanaged file instead of failing on collision; no set value is lost.
- Home Manager also sets `logs.dir` to `~/.local/state/atuin/logs` because the profile prefers XDG directories.
- History databases, the local encryption `key` and any future sync session stay in `~/.local/share/atuin`. The owner does not use sync yet, so `SETUP.md` has no login step.

## Validation

`just build-home personal hamishwhc` and `just build-home atlassian hcox` passed on 2026-10-25. The generated `config.toml` contains the declared settings and `.zshrc` initializes Atuin once. No switch was performed.

## Remaining human verification

- After switching, confirm Ctrl-R/up-arrow open Atuin with existing history and that Enter runs the selected command.
