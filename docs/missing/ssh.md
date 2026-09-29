# SSH: create the connection socket directory

Status: Implemented; awaiting human activation. Priority: High. Dependencies: None.

## Current state

[ssh-client.nix](../../modules/features/cli/ssh-client.nix) uses `~/.ssh/sockets/%r@%h:%p` for `ControlPath` and creates the socket directory during Home Manager activation. The path uses the configured home directory, and activation runs as the home user.

## Work

The `createSshSocketDirectory` activation entry runs after `writeBoundary` and uses Home Manager's `run` helper to respect dry runs. It creates the directory with mode `0700` and reapplies that mode to the directory itself on subsequent activation. Existing sockets and other SSH permissions are preserved, as are the SSH configuration and its includes. The obsolete manual directory-creation command has been removed from `SETUP.md`.

## Acceptance

- A new home activation creates the required directory before SSH needs it.
- Subsequent activation preserves existing socket files and does not recursively reset unrelated SSH permissions.
- No private keys, host inventories or connection state are added to Nix.
- Validate through `just build-home` as described in [README.md](README.md#validation); leave switching to the human.

Validation: `just build-home atlassian hcox` and `just build-home personal hamishwhc` both passed. No system switch or live activation was performed.

Manual follow-up: after switching, confirm ordinary SSH/Git connections can use multiplexing without a missing-directory error.
