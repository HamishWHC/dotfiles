# Git: point global excludes at the existing file

Status: Open. Priority: High. Dependencies: None.

## Current state

[git.nix](../../modules/features/cli/git.nix) creates `~/.config/git/ignore` but sets `core.excludesfile` to `~/.config/ignore`. The created file is correct; the setting is wrong. The incorrectly referenced file was absent on the audited Mac.

## Work

Set `core.excludesFile` to `${config.xdg.configHome}/git/ignore` (Git's key capitalization is not the underlying problem). Keep the created file, its contents, existing identity includes, URL rewrites and other Git preferences in place.

The earlier audit also mentioned work identity/signing. Do not invent a work identity or enable signing as part of this focused correction; existing local includes remain available.

## Acceptance

- The generated Git configuration references the file actually managed by Home Manager.
- No file is moved to `~/.config/ignore` to accommodate the bad setting.
- Existing ignore entries and other Git settings remain intact.
- Complete the relevant `just build-home` checks under the [backlog rules](README.md#validation). No system switch.

After a human switch, the existing global ignore patterns should apply to repositories without a per-repository override.
