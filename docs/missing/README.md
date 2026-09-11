# macOS configuration backlog

These are implementation tickets from the application audit and the owner's corrections. Creating these tickets does **not** implement their proposed changes. Scope is macOS (`personal` and `atlassian`) first. Local observations describe one Mac, not both hosts or a clean installation.

Each ticket records the current state, intended result, boundaries, implementation starting points, and acceptance criteria. Read this file and the repository [AGENTS.md](../../AGENTS.md) before taking a ticket. Update the ticket's status when work is finished, and record any remaining manual steps in [SETUP.md](../../SETUP.md).

## Tickets

Priority is an implementation suggestion, not a dependency. All tickets start open.

| Ticket | Priority | Dependency / coordination |
| --- | --- | --- |
| [Git](git.md) | High | Independent |
| [SSH](ssh.md) | High | Independent |
| [Firefox](firefox.md) | High | Owns Firefox profile and extension installation |
| [Proxy SwitchyOmega](proxy-switchyomega.md) | High | Firefox profile contract; coordinate Chromium support |
| [Ungoogled Chromium](ungoogled-chromium.md) | Normal | Coordinate browser module edits |
| [Velja](velja.md) | Normal | Coordinate browser module edits |
| [Rectangle](rectangle.md) | High | Coordinate macOS utility module imports |
| [Thaw](thaw.md) | High | Coordinate macOS utility module imports |
| [Shottr](shottr.md) | High | Owns both Shottr settings and license; needs purchased key |
| [Burp Suite](burp-suite.md) | High | Certificate source needed for trust provisioning |
| [Aptakube license](aptakube.md) | High | Needs license key or supported transferable license file |
| [Mission Control Plus license](mission-control-plus.md) | Normal | Needs entitlement material; configuration stays local |
| [Atuin](atuin.md) | Normal | Independent |
| [AWS CLI / AWSume](aws.md) | High | Independent; work-side profile details may remain local |
| [Docker / OrbStack](orbstack.md) | High | Keep Kubernetes state local; use OrbStack Free |
| [Shared AI options](ai-shared.md) | High | Establish the contract before merging client adapters |
| [Codex](codex.md) | High | Shared AI options |
| [Claude Code](claude-code.md) | High | Shared AI options |
| [Paseo](paseo.md) | High | Shared AI options and client adapters for end-to-end integration |
| [Shell utilities](shell-utilities.md) | Low | Optional targeted preferences; coordinate Zsh edits |

Programs intentionally left alone, including locally managed VS Code/Codium settings, are documented in [local-and-deferred.md](local-and-deferred.md). An exclusion is not an invitation to create another implementation ticket.

## Working independently

- Give each agent one ticket and its linked dependencies. Do not expand into adjacent applications.
- Prefer separate feature files, following this repo's dendritic module structure. Suggested new paths are starting points, not requirements to introduce a new framework.
- `modules/features/applications/browsers.nix`, `modules/features/applications/macos-necessities/default.nix`, `modules/features/applications/ai.nix`, profile lists, `SETUP.md`, and `secrets/default.yaml` are shared integration points. Coordinate small additive edits or serialize their integration; independent tickets do not make concurrent writes to the same file safe.
- Put app-specific secret declarations beside their feature when practical. Reuse the existing SOPS configuration rather than replacing the shared secrets module.
- Establish the shared AI option contract first. Codex and Claude adapters can then be implemented separately. Paseo should reuse those adapters rather than generate competing copies of their files.
- A ticket may be implemented and build-validated while real activation remains awaiting an owner-provided secret or a human system switch. Report those states separately; do not claim a successful live activation without evidence.

## Configuration and activation rules

- Inspect the pinned packages/modules and current app settings before choosing configuration keys. Audit observations can become stale.
- Preserve existing local state. Import selected settings, not entire preference databases containing history, tokens, device identifiers, migrations, or licenses.
- App-owned mutable files need a supported import, selective merge, or suitable configuration interface. Do not blindly replace them with immutable symlinks.
- Make changes conditional on the corresponding feature. In particular, native screenshot shortcuts must only be disabled when Shottr is included.
- Handle repeated activation, changes to managed values, and removal of managed settings. Do not delete unrelated local settings when a feature is removed.
- Use host/user parameters; do not embed this Mac's username or absolute home directory in shared configuration.

## License and secret contract

The owner prefers automatic license management through SOPS. Add real license keys/files as encrypted values in `secrets/default.yaml`, then expose them through `sops.secrets` or runtime templates with restrictive ownership and permissions. Proposed YAML paths, reserved to avoid collisions:

| Application | Proposed secret path | Owner |
| --- | --- | --- |
| Shottr | `licenses/shottr/key` | Shottr ticket |
| Aptakube | `licenses/aptakube/key` or `licenses/aptakube/file` | Aptakube ticket; choose the supported format |
| Mission Control Plus | `licenses/mission_control_plus/key` or `licenses/mission_control_plus/file` | Mission Control Plus ticket |

These paths do not exist merely because this document lists them. If a file is binary, define its encoding and decode it only at runtime. Do not put a Nix path to a plaintext license in a derivation or decode secrets during evaluation. Do not print license values in build/activation logs or ticket text. Preserve the existing encrypted GitHub token and SOPS metadata when editing the file.

Implement automatic activation when supported, not just secret-file delivery. If an app has no usable noninteractive activation/import method, implement secure secret delivery and document the exact remaining UI operation and evidence for the limitation. Do not substitute cached `isLicensed` flags for activation or repeatedly consume device activations on every rebuild.

Mac Mouse Fix is an explicit exception: its existing module and licensing state are to remain unchanged. OrbStack is Free and gets no license provisioning. App Store/Microsoft purchases and service sign-ins remain local as recorded in the exclusions and setup guide.

## Validation

Only use `just build-home` and `just build-system` to test changes, with the applicable `personal` or `atlassian` host argument. Run home builds for Home Manager work and system builds for Darwin settings/secrets/integration. Cover both macOS hosts when shared changes affect both; coordinate builds because these recipes share the `result` link.

Never run a system switch, including through helper commands. Do not replace these checks with `nix flake check`, direct `nix build`, standalone test scripts, or application launches that mutate the live system. Explain when the human should switch. Record post-switch checks in `SETUP.md` for the human to perform; builds alone do not establish GUI permissions, certificate trust, or license validity.
