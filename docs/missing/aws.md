# AWS CLI and AWSume: shell integration and profile defaults

Status: Implemented and build-validated. Regions, profiles and authentication remain local by owner decision.

## Implementation

- `programs.zsh.shellAliases.awsume` sources the Nix-packaged `bin/awsume` script by absolute path. Arguments pass through to the script, which updates the current shell. The package's existing Zsh completion is retained.
- Home Manager activation uses `aws configure set` to manage only `[default]` output (`json`) in `~/.aws/config`. AWS's writer preserves regions, other keys, comments, named profiles and SSO sections; no immutable config symlink or state file is introduced. Removing a declaration stops writing that key and leaves its current value intact.
- Named profiles remain locally editable, including account/role identifiers, SSO sessions and credential-process commands. `[default]` settings are not inherited by named profiles; configure those profiles' region/output locally as needed. Credentials and caches remain unmanaged, and authentication commands never run during activation.
- The inspected local config uses `aws login` for console-login profiles and AWS IAM Identity Center for course profiles. AWSume 4.5.5 supports the existing `credential_process = aws configure export-credentials ... --format process` bridge; log into the source profile, then use `awsume <proxy-profile>`. Work authentication and the existing ACLI/KITT integration are unchanged. Manual restoration and sign-in steps are in `SETUP.md`.
- All credential-process mappings remain local and outside Nix's scope, including the course proxy profiles.

References: [AWS configure set](https://docs.aws.amazon.com/cli/latest/reference/configure/set.html), [console login and credential-process bridge](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sign-in.html), [IAM Identity Center](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sso.html).

## Validation

Passed `just build-home personal` and `just build-home atlassian hcox` with the output-only defaults. No system switch, AWS login or cloud operations were performed; live profile assumption remains untested.

## Original state

[aws.nix](../../modules/features/cli/cloud/aws.nix) previously only installed `awscli2` and `awsume`. The Nix package inspected during the audit disables AWSume's automatic alias setup, and the repo did not supply the required sourcing alias/function. A local `~/.aws/config` existed.

## Work

- Add the Zsh sourcing integration AWSume requires to update the parent shell, using the packaged script correctly and preserving argument forwarding.
- Preserve package-provided completions; do not add duplicate completion/initialization machinery unnecessarily.
- Manage default JSON output while keeping all regions, profiles and SSO structure local, as requested by the owner. Preserve the writable AWS config through selective updates; AWS config is not an arbitrary shell include file.
- Keep access keys, session credentials and SSO caches out of ordinary Nix configuration. Document the actual authentication route; do not introduce a new work authentication mechanism.

## Acceptance

- The generated shell configuration sources AWSume correctly; a human can assume a configured profile in the current shell after switching.
- Declared defaults do not erase local AWS profiles or credential/session files.
- Existing work-side tooling remains usable.
- Record SSO/login steps and any intentionally local profile data in `SETUP.md`.
- Validate only through the [allowed build recipes](README.md#validation); do not log into AWS or make cloud changes as part of this ticket.

Reference: [AWSume alias setup](https://awsu.me/general/quickstart.html#alias-setup).
