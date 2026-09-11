# SSH: create the connection socket directory

Status: Open. Priority: High. Dependencies: None.

## Current state

[ssh-client.nix](../../modules/features/cli/ssh-client.nix) uses `~/.ssh/sockets/%r@%h:%p` for `ControlPath` but does not create `~/.ssh/sockets`. The directory exists on the audited Mac, so the gap concerns repeatable setup on a new home directory.

## Work

Create the socket directory through Home Manager activation using the configured home directory, user ownership, and mode `0700`. Respect Home Manager activation conventions. Preserve existing sockets and the SSH configuration, including work-generated includes and OrbStack's include.

## Acceptance

- A new home activation creates the required directory before SSH needs it.
- Subsequent activation preserves existing socket files and does not recursively reset unrelated SSH permissions.
- No private keys, host inventories or connection state are added to Nix.
- Validate through `just build-home` as described in [README.md](README.md#validation); leave switching to the human.

Manual follow-up: after switching, confirm ordinary SSH/Git connections can use multiplexing without a missing-directory error.
