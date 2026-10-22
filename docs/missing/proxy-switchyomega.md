# Proxy SwitchyOmega: portable proxy profiles

Status: Deferred by owner decision on 2026-10-22: skip proxy extensions for now. Configuration research is retained below; do not install SwitchyOmega or an alternative without renewed scope. No runtime configuration was applied.

## Current state

The original audit found the `switchyomega@feliscatus.addons.mozilla.org` extension installed locally in Firefox. Neither extension installation nor its proxy profiles/rules are represented in the repo. Firefox's ticket owns installation; this ticket owns the extension's configuration.

## Configuration research (2026-10-22)

Firefox's [`3rdparty.Extensions` policy](https://firefox-admin-docs.mozilla.org/reference/policies/3rdparty/) exposes configuration through `storage.managed`; the extension must explicitly read it. Ordinary browser preferences do not populate an extension's settings automatically.

| Candidate | Configuration support | Fit for local proxy selection |
| --- | --- | --- |
| Original SwitchyOmega | No managed-storage/policy reader found in upstream source. Options use local/sync storage; the UI imports `OmegaOptions.bak` from a file or URL. | A generated backup plus manual import preserves ordinary switching. No supported unattended provisioning route was found. |
| ZeroOmega | No managed-storage/policy reader found in the inspected fork either. | Switching to this fork alone does not solve declarative provisioning. |
| FoxyProxy Standard | Documented Firefox enterprise-policy and native managed-storage support, using its export-format configuration. | Managed mode locks whole-browser mode/proxy selection and option saving. Firefox per-tab proxy selection remains available. |
| Firefox's built-in Proxy policy / PAC | Official support for manual endpoints, bypass lists or a PAC URL, with an optional lock. | Useful for one proxy or automatic rules; it does not provide SwitchyOmega's menu of named profiles. |

SwitchyOmega evidence: upstream snapshot `19f9d73f20125b6164fb95d17cd4cc6659df147c`, specifically [background initialization](https://github.com/FelisCatus/SwitchyOmega/blob/19f9d73f20125b6164fb95d17cd4cc6659df147c/omega-target-chromium-extension/src/coffee/background.coffee) and [import/export controller](https://github.com/FelisCatus/SwitchyOmega/blob/19f9d73f20125b6164fb95d17cd4cc6659df147c/omega-web/src/omega/controllers/io.coffee). Its external extension API only offers restricted enable/disable/get-options operations, not a configuration import endpoint. The upstream repository also labels the original project unmaintained. ZeroOmega snapshot inspected: `c367db220e2a3af1c65e5afffa4cf42c949f2908` ([source](https://github.com/zero-peak/ZeroOmega/tree/c367db220e2a3af1c65e5afffa4cf42c949f2908)). These are source-review conclusions, not live extension tests.

FoxyProxy's [enterprise-policy documentation](https://foxyproxy.github.io/browser-extension/src/content/help.html) specifies extension ID `foxyproxy@eric.h.jung`, a `mode` value and a `data` array of proxies. The Nix integration point is `programs.firefox.policies."3rdparty".Extensions."foxyproxy@eric.h.jung"`. On macOS, encode that extension's object with `builtins.toJSON` to preserve JSON value types through plist policy delivery, as Mozilla documents. A native managed-storage JSON manifest is another supported delivery mechanism.

FoxyProxy 9.8 source snapshot `ab9e6d5acb5cb35067f746fac4c1149b6da6ccf9` confirms the important restrictions:

- [`Sync.getManaged`](https://github.com/foxyproxy/browser-extension/blob/ab9e6d5acb5cb35067f746fac4c1149b6da6ccf9/src/content/sync.js) resets known preferences to defaults, overlays managed data, sets `managed = true`, disables sync, and writes those values into local storage. It does not merge a managed proxy list with the user's existing list or preserve the existing mode when mode is omitted.
- [`commands.js`](https://github.com/foxyproxy/browser-extension/blob/ab9e6d5acb5cb35067f746fac4c1149b6da6ccf9/src/content/commands.js) blocks global switching while managed, but explicitly allows set/unset Tab Proxy. The [popup](https://github.com/foxyproxy/browser-extension/blob/ab9e6d5acb5cb35067f746fac4c1149b6da6ccf9/src/content/popup.js) likewise retains the per-tab selector. This offers a potential Burp workflow: managed proxy definitions, normal mode disabled, and user-selected proxying for individual tabs. It is not equivalent to whole-browser switching.

The pinned Home Manager `profiles.<name>.extensions.settings` option is a separate possible storage override, not enterprise policy. It disables `extensions.webextensions.ExtensionStorageIDB.enabled` profile-wide and force-writes an extension's `browser-extension-data/<id>/storage.js`. Because that replaces mutable extension state and changes the profile's storage backend, it is not a suitable default implementation for this ticket's preservation requirements; compatibility has not been tested here.

Recommendation: FoxyProxy is a verified policy-capable alternative if per-tab selection or fixed automatic rules fit the intended workflow. For ordinary whole-browser switching with preserved local state, use a generated import artifact unless a better supported mechanism is found. Firefox's [native Proxy policy](https://firefox-admin-docs.mozilla.org/reference/policies/proxy/) is also viable if named-profile switching is unnecessary. Actual proxy endpoints, existing configuration migration and any replacement choice remain implementation inputs. No browser was launched, proxy setting changed, extension installed, or build run for this research.

## Work

- Inspect the installed extension/version and supported configuration backup/import, sync, or managed-storage interfaces. Prefer a portable export over copying browser storage databases.
- Represent intended proxy endpoints, bypass rules, profile names, automatic-switch rules and any rule-list source. A reusable local Burp proxy profile is useful; take its actual endpoint from the Burp configuration rather than assuming a port.
- Preserve the currently selected profile as local runtime state unless the owner chooses a fixed default.
- Keep passwords/tokens in SOPS when required; avoid leaking private work routing rules into public configuration. Provide host-specific inputs where necessary.
- Determine whether the settings can be applied automatically without resetting unrelated extension state. Do not assume arbitrary `storage.local` databases are declarative configuration files.
- Add Chromium support only for a verified compatible installed extension/version. Do not silently replace SwitchyOmega with a fork or unrelated proxy extension.

## Acceptance

- Portable profiles/rules are represented and the supported import path is documented.
- Automatic provisioning is implemented if the installed extension supports it. If not, provide the export artifact and exact manual import instructions, explicitly recording the limitation.
- Reapplying settings preserves unrelated extension data and does not force a proxy for every browser session.
- Document any dependency on Burp being started and on its CA trust setup.
- Build through the commands in [README.md](README.md#validation); extension import and proxy checks are human post-switch steps.

Starting point: [SwitchyOmega upstream](https://github.com/FelisCatus/SwitchyOmega), plus the installed extension's options/export format.
