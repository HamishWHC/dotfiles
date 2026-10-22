# Git: point global excludes at the existing file

Status: Implemented and build-validated on 2026-10-22; awaiting human activation. Priority: High. Dependencies: None.

## Current state

[git.nix](../../modules/features/cli/git.nix) now sets `core.excludesfile` to `${config.xdg.configHome}/git/ignore`, matching the file managed by Home Manager. Previously it referenced `${config.xdg.configHome}/ignore` instead.

The existing ignore patterns, identity includes, URL rewrites and other Git preferences are unchanged.

## Validation

- Passed on 2026-10-22: `just build-home personal hamishwhc` and `just build-home atlassian hcox`.
- No system switch or live activation was performed.

The earlier audit also mentioned work identity/signing. Do not invent a work identity or enable signing as part of this focused correction; existing local includes remain available.

## Acceptance

- The generated Git configuration references the file actually managed by Home Manager.
- No file is moved to `~/.config/ignore` to accommodate the bad setting.
- Existing ignore entries and other Git settings remain intact.
- Complete the relevant `just build-home` checks under the [backlog rules](README.md#validation). No system switch.

After a human switch, the existing global ignore patterns should apply to repositories without a per-repository override.
