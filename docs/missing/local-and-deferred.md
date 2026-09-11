# Programs intentionally left local or unchanged

Status: Excluded from implementation, by owner decision or because the audit found no actionable gap. This file preserves the complete review disposition so agents do not reopen rejected work.

## Explicit owner decisions

| Program / area | Audit observation | Decision |
| --- | --- | --- |
| VS Code | Extensive local settings, three keybinding entries, some stale settings such as an iTerm reference | Keep editor settings local. Do not import settings, keybindings, snippets or profiles into Nix. |
| VSCodium | The existing repo assigns its extension list and update settings here, separately from VS Code | Preserve the current separation. Do not move/copy that list to VS Code as a purported wiring fix. No editor migration ticket. |
| Editor fonts | Local VS Code requests FiraCode Nerd Font / Fira Code; no font package is declared | Leave with the local editor setup for now; do not use the audit to expand into editor migration. |
| Raycast | Hotkeys, extensions, snippets and other preferences are not captured | Exclude configuration and license/account automation. The owner plans to replace Raycast; this backlog does not select a replacement or remove the installed app. |
| Mac Mouse Fix | The repo already manages the plist, including cached licensing state | Leave module, settings and license handling unchanged. The general SOPS license preference does not override this explicit exception. |
| Aptakube preferences | Local terminal/proxy/kubeconfig/theme/column preferences exist | Keep all preferences and cluster state local. Only the [license ticket](aptakube.md) is active. |
| Thaw hidden/always-hidden applications | Local layout, membership and order are mixed with general preferences | Must remain local even while [portable Thaw preferences](thaw.md) become managed. |
| Wireshark | Profiles, filters and capture permissions could be documented | Rarely used; no configuration or packet-capture setup ticket. |
| Ghidra | Preferences, scripts and extensions could be captured | Rarely used; no configuration ticket. |
| Hex Fiend | Local inspector/representation and bytes-per-line settings exist | Rarely used; no configuration ticket. |
| Mission Control Plus preferences | Local launch/menu-bar preferences exist | Ordinary preferences stay local under the utility exclusion. Only its [license ticket](mission-control-plus.md) is active. |
| Black Out | Potential display/shortcut preferences | Manage locally. |
| HEIC Converter | Potential output/quality preferences | Manage locally. |
| Shareful | Potential share action preferences | Manage locally. |
| UTC Time | Potential display preferences | Manage locally. |
| The Unarchiver | Extraction preferences and file associations | Manage locally. |
| Presentify | Local annotation/highlight/zoom shortcuts exist | Preferences and App Store purchase restoration remain local. |
| GrandPerspective | Potential scan/display preferences | Manage locally. |
| Microsoft Word | Editing preferences, templates and activation | Manage locally, including Microsoft/App Store account restoration. |
| Microsoft Excel | Editing preferences, templates and activation | Manage locally, including Microsoft/App Store account restoration. |
| MeetingBar | Calendar/event filters and meeting behaviour | Manage locally on the work Mac. |
| ACLI | Work authentication and profile setup | Manage locally through work tooling. |
| Okta Verify | Enrollment and authentication state | Manage locally through employer-supported setup. |
| Kubernetes tooling | kubectl, kubectx/kubens, kubecm, Helm, kapp, kbld, yq and k3d | No new configuration. Clusters remain local. Preserve existing KITT integration and package/alias declarations. |
| Rustup | A default toolchain exists locally but is not declared | Leave as-is; no toolchain bootstrap ticket. |
| Terraform / OpenTofu | Optional provider cache/CLI defaults could be added | Leave as-is. |
| SecretSpec | Installation only | Leave as-is. |
| OrbStack licensing | The audit considered commercial-license provisioning | Owner uses **Free**. No paid license, Pro settings or license secret. [Runtime settings remain in scope](orbstack.md). |

## Already configured or no compelling additional global configuration

| Programs | Existing coverage / disposition |
| --- | --- |
| Ghostty | Extensive config and Finder service already tracked; leave as-is. |
| Zsh / Powerlevel10k / z / fzf-tab | Shell behaviour, prompt, plugins and local extension points already tracked. Only focused integration work from active tickets is needed. |
| Node.js / Corepack / pnpm / Yarn | Version selection, writable Corepack home and declarative shims already covered. |
| Go | Home Manager enablement and XDG GOPATH already covered. |
| Bun / uv / Zig | No compelling missing global settings identified; keep project choices in projects. |
| nixfmt / nixd / nil / just-lsp | Installed; editor integration remains local by owner decision. |
| Lima | Repo already contains a NixOS VM template and lifecycle recipes; no additional global configuration ticket. |
| Nix / Determinate / Home Manager / Homebrew / mas | Core setup and update behaviour already declared; this backlog does not redesign package management. |
| SOPS / age / age-plugin-se | Existing encrypted-secret infrastructure and onboarding are present; extend for active license tickets only. |
| jq / jqp / gum / cloc / just | No necessary extra global config identified. |
| XDG / hushlogin | Already configured. |

## Related service accounts

Firefox extensions may depend on Kagi, 1Password and AdGuard accounts or companion apps. Their extension installation/preferences are in scope for [Firefox](firefox.md), but this backlog does not add desktop applications, transfer subscriptions, or copy authenticated browser state. Document account/companion-app prerequisites in [SETUP.md](../../SETUP.md).

App Store ownership and Microsoft/service account sign-ins do not become portable activation simply by storing a receipt or token in SOPS. License-key/file automation is scoped to the explicit Shottr, Aptakube and Mission Control Plus tickets. Burp's selected cask is Community Edition, so there is no Professional activation ticket.
