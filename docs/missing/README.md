# macOS configuration backlog

These are implementation tickets from the application audit and the owner's corrections. Creating these tickets does **not** implement their proposed changes. Scope is macOS (`personal` and `atlassian`) first. Local observations describe one Mac, not both hosts or a clean installation.

Each ticket records the current state, intended result, boundaries, implementation starting points, and acceptance criteria. Read this file and the repository [AGENTS.md](../../AGENTS.md) before taking a ticket. Update the ticket's status when work is finished, and record any remaining manual steps in [SETUP.md](../../SETUP.md).

## Tickets

Priority is an implementation suggestion, not a dependency.

The 16 previously open tickets were reassessed against repository source on 2026-10-22. The initial assessment was a source review, with no new builds, activation, or live application checks. Git was subsequently fixed and both macOS home builds passed; human activation remains outstanding. Firefox, Rectangle and Shottr have partial implementation. The shell-utilities ticket remains optional and has no demonstrated missing preference. Previously implemented tickets retain their recorded validation status.

| Ticket | Priority | Status / remaining work |
| --- | --- | --- |
| [Git](git.md) | High | Implemented and build-validated for both macOS hosts: `core.excludesfile` now targets the managed `git/ignore`. Awaiting human activation. |
| [SSH](ssh.md) | High | Implemented and build-validated; human activation remains outstanding in the ticket. |
| [Firefox](firefox.md) | High | Seven extensions declared, including React Developer Tools. Owner accepted bookmarks and Refined GitHub, excluded AdGuard/Wappalyzer/right-click extension; Unhook lacks managed-policy support. Existing-profile migration documentation remains. |
| [Proxy SwitchyOmega](proxy-switchyomega.md) | High | Deferred by owner: skip proxy extensions for now. Policy-support research retained in ticket. |
| [Ungoogled Chromium](ungoogled-chromium.md) | Normal | Closed by owner: keep the existing installation as a secondary browser for site testing; no additional configuration required. |
| [Velja](velja.md) | Normal | Implemented: Nix defaults declare Firefox, Chromium, Safari, Firefox (Private), in order. Default browser, rules and profiles stay local. Human activation remains. |
| [Rectangle](rectangle.md) | High | Implemented: existing Homebrew cask and selected portable preferences/shortcuts in a focused feature. Human activation and permission persistence remain unverified. |
| [Thaw](thaw.md) | High | Implemented: portable behaviour via Nix defaults. Hidden-app membership/order, displays and unassigned hotkeys stay local. Human activation remains. |
| [Shottr](shottr.md) | High | Partial: package and encrypted `shottr_license_key` exist. Settings, shortcuts, runtime secret delivery and activation remain; macOS currently enables the conflicting native screenshot shortcuts. |
| [Burp Suite](burp-suite.md) | High | Open: cask installation only; reusable settings/listeners, CA input, Keychain trust lifecycle and browser trust integration remain. |
| [Aptakube license](aptakube.md) | High | Implemented and build-validated on macOS; human activation remains outstanding in the ticket. Linux license-path support is explicitly deferred. |
| [Mac Mouse Fix](mac-mouse-fix.md) | Normal | Implemented: settings and interactive native license setup during activation; see ticket for validation and platform limitations. |
| [Atuin](atuin.md) | Normal | Open: package and one Zsh initialization exist; portable settings such as `enter_accept` and sync preferences are not managed. |
| [AWS CLI / AWSume](aws.md) | High | Implemented and build-validated: Zsh integration and default JSON output; regions, profiles and authentication intentionally remain local. |
| [Docker / OrbStack](orbstack.md) | High | Open: packages, client ownership and SSH include exist; runtime preferences, CLI prompt diagnosis and selective Docker context/credential-helper setup remain. Use OrbStack Free. |
| [Shared AI options](ai-shared.md) | High | Open: no common MCP/skills/instructions options, override rules or runtime-secret contract. Establish these before client adapters. |
| [Codex](codex.md) | High | Open: package installation only; native preferences and shared MCP/skills/instructions adapter remain. Depends on shared AI options. |
| [Claude Code](claude-code.md) | High | Open: package installation only; native preferences and shared MCP/skills/instructions adapter remain. Depends on shared AI options. |
| [Paseo](paseo.md) | High | Open: cask installation only; desktop/daemon settings and GUI-launched agent integration remain. Depends on shared AI options and adapters. |
| [Shell utilities](shell-utilities.md) | Low | Optional inventory: packages, fzf-tab and bat pagers already exist. Identify an actual portable preference gap or close with evidence that the existing setup suffices. |

Existing local configuration is not evidence that a setting is reproducible from this repository. Conversely, an unmanaged optional preference is not automatically a defect. Older acceptance text about resetting removed settings or adding validation checks to `SETUP.md` is subordinate to [AGENTS.md](../../AGENTS.md): preserve existing values when ownership ends, and keep verification notes in tickets.

Programs intentionally left alone, including locally managed VS Code/Codium settings, are documented in [local-and-deferred.md](local-and-deferred.md). An exclusion is not an invitation to create another implementation ticket.

## Working independently

- Give each agent one ticket and its linked dependencies. Do not expand into adjacent applications.
- Prefer separate feature files, following this repo's dendritic module structure. Suggested new paths are starting points, not requirements to introduce a new framework.
- `modules/features/applications/browsers/default.nix`, `modules/features/applications/macos-necessities/default.nix`, `modules/features/applications/ai.nix`, profile lists, `SETUP.md`, and `secrets/default.yaml` are shared integration points. Coordinate small additive edits or serialize their integration; independent tickets do not make concurrent writes to the same file safe.
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
| Shottr | `shottr_license_key` | Existing encrypted key; runtime delivery and activation remain in the Shottr ticket |
| Aptakube | `aptakube_license_key` | Original key; runtime provisioning preserves the app's token |
| Mac Mouse Fix | `mac_mouse_fix_license_key` | Original key; terminal prompt and native dialog during activation |

These paths do not exist merely because this document lists them. If a file is binary, define its encoding and decode it only at runtime. Do not put a Nix path to a plaintext license in a derivation or decode secrets during evaluation. Do not print license values in build/activation logs or ticket text. Preserve the existing encrypted GitHub token and SOPS metadata when editing the file.

Implement automatic activation when supported, not just secret-file delivery. If an app has no usable noninteractive activation/import method, implement secure secret delivery and document the exact remaining UI operation and evidence for the limitation. Do not substitute cached `isLicensed` flags for activation or repeatedly consume device activations on every rebuild.

Mac Mouse Fix settings and SOPS key delivery are in scope; its signed app owns the Keychain license entry and runtime license caches. OrbStack is Free and gets no license provisioning. App Store/Microsoft purchases and service sign-ins remain local as recorded in the exclusions and setup guide.

## Validation

Only use `just build-home` and `just build-system` to test changes, with the applicable `personal` or `atlassian` host argument. Run home builds for Home Manager work and system builds for Darwin settings/secrets/integration. Cover both macOS hosts when shared changes affect both; coordinate builds because these recipes share the `result` link.

Never run a system switch, including through helper commands. Do not replace these checks with `nix flake check`, direct `nix build`, standalone test scripts, or application launches that mutate the live system. Explain when the human should switch. Record validation evidence and outstanding runtime verification in the relevant ticket; builds alone do not establish GUI permissions, certificate trust, or license validity. `SETUP.md` contains only necessary manual setup steps, never validation checks or troubleshooting for Nix-managed configuration.
