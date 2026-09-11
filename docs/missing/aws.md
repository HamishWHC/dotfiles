# AWS CLI and AWSume: shell integration and profile defaults

Status: Open. Priority: High. Dependencies: None; work-specific SSO/profile inputs may require local configuration.

## Current state

[aws.nix](../../modules/features/cli/cloud/aws.nix) installs `awscli2` and `awsume` only. The Nix package inspected during the audit disables AWSume's automatic alias setup, and the repo does not supply the required sourcing alias/function. A local `~/.aws/config` exists.

## Work

- Add the Zsh sourcing integration AWSume requires to update the parent shell, using the packaged script correctly and preserving argument forwarding.
- Preserve package-provided completions; do not add duplicate completion/initialization machinery unnecessarily.
- Capture appropriate non-secret defaults such as region/output and reusable profile/SSO structure. Allow work/private profiles to remain local through a supported merge/input design; AWS config is not an arbitrary shell include file.
- Keep access keys, session credentials and SSO caches out of ordinary Nix configuration. Document the actual authentication route; do not introduce a new work authentication mechanism.

## Acceptance

- The generated shell configuration sources AWSume correctly; a human can assume a configured profile in the current shell after switching.
- Declared defaults do not erase local AWS profiles or credential/session files.
- Existing work-side tooling remains usable.
- Record SSO/login steps and any intentionally local profile data in `SETUP.md`.
- Validate only through the [allowed build recipes](README.md#validation); do not log into AWS or make cloud changes as part of this ticket.

Reference: [AWSume alias setup](https://awsu.me/general/quickstart.html#alias-setup).
