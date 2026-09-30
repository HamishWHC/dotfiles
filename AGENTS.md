# Agent Instructions

## Settings ownership

- Removing a setting from Nix makes it unmanaged. Preserve its existing value; do not reset or delete it.

## Testing

- Only use `just build-home` and `just build-system` to test changes.
- Never run a system switch. Instead, inform the human when a system switch may be appropriate so they can decide whether to perform it.

## Setup documentation

- `SETUP.md` contains only strictly necessary manual steps to reach a configured macOS system.
- Do not add validation checklists, troubleshooting, implementation details, or instructions to verify Nix-managed settings. This also applies when backlog tickets request post-switch checks in `SETUP.md`.
