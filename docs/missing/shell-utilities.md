# fzf, bat and ripgrep: selected portable preferences

Status: Open, optional. Priority: Low. Dependencies: None; coordinate edits to Zsh with Atuin/AWS tickets.

## Current state

[dotfiles.nix](../../modules/features/dotfiles.nix) installs fzf, bat and ripgrep. [zsh/default.nix](../../modules/features/cli/zsh/default.nix) already configures fzf-tab and bat-based pagers. Zsh/Powerlevel10k and Ghostty have substantial configuration; they do not need replacement.

## Work

Inventory only actual useful local preferences that are missing: fzf default/preview commands and optional shell bindings, bat display/theme choices, or ripgrep defaults. Capture selected settings if present or explicitly chosen. Do not add speculative customization merely because a tool supports a config file.

Any new bindings must coexist with fzf-tab and Atuin. Search defaults must document whether hidden/ignored files are included; avoid silently changing discovery behaviour globally. Keep machine-local history and caches local.

## Acceptance

- Either a small justified set of portable settings is captured, or this ticket is closed with evidence that existing defaults/integration suffice.
- No duplicate shell initialization or conflicts with Atuin/fzf-tab are introduced.
- Existing Ghostty, Zsh/Powerlevel10k and pager behaviour remains intentional.
- Use only `just build-home` as applicable under [README.md](README.md#validation); any interactive keyboard checks are human follow-up.
