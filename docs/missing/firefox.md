# Firefox: profiles, extensions and portable preferences

Status: Managed extension selection implemented and both macOS home builds passed; owner decisions and Unhook research recorded on 2026-10-22. Existing-profile migration documentation remains open. Priority: High. Dependencies: None. Proxy extensions are deferred by owner decision.

## Current state

[browsers/default.nix](../../modules/features/applications/browsers/default.nix) imports the focused [firefox.nix](../../modules/features/applications/browsers/firefox.nix) feature. It declares a default `personal` profile named Personal, `DisableAppUpdate`, disabled password saving, other policies, portable preferences, toolbar layout and bookmarks. On macOS it installs `firefox-bin-unwrapped` and sets `MOZ_LEGACY_PROFILES` during activation.

Seven extension packages are declared: uBlock Origin, 1Password, React Developer Tools, Refined GitHub, Kagi Privacy Pass, Kagi Search and `youtube-recommended-videos` (the Unhook package).

The owner explicitly requested React Developer Tools, skipped AdGuard Browser Assistant, Wappalyzer and Absolute Enable Right Click & Copy, deferred proxy extensions, accepted Refined GitHub as configured, and confirmed that the existing managed bookmarks should remain unchanged. These choices resolve the old extension-inventory and bookmark-ownership questions. Do not restore excluded extensions or change bookmark behaviour to satisfy the original audit.

Existing-profile migration and the browser-service setup instructions still need to reflect the managed Personal profile. Unhook preferences remain local because the packaged extension does not support managed policies, as detailed below.

## Unhook managed-policy support

Read-only inspection of the packaged Unhook 1.6.9 XPI (`youtube-recommended-videos`, extension ID `myallychou@gmail.com`) on 2026-10-22 found no managed-storage reader. Its background script, popup and content script select `storage.sync` when available and fall back to `storage.local` on errors. No code reads `storage.managed`, so Firefox's `3rdparty.Extensions` policy cannot configure its hide/show preferences. Ordinary Firefox preferences do not populate those extension storage areas either.

The [official Firefox listing](https://addons.mozilla.org/en-US/firefox/addon/youtube-recommended-videos/) documents configuration through the extension popup and lists the same version. [Mozilla's managed-storage documentation](https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/API/storage/managed) describes the separate API an extension must read. Home Manager's forced local-storage override is not equivalent: Unhook prefers sync storage, and the override would also replace mutable state and change the profile's storage backend. No such override or policy was added.

The evidence was the shipped `manifest.json`, `js/background.js`, `js/popup.js`, `js/content.js` and `js/info-popup.js`; no browser was launched and no extension settings were changed.

## Other implementation notes

Further source inspection on 2026-10-22 narrowed two earlier findings:

- The packaged Kagi Search 0.7.6 manifest already declares the Kagi search provider with `is_default = true`. Default search is therefore requested by the installed extension. There is no explicit `SearchEngines.Default` policy, but that is only additional work if unattended policy selection is wanted. Firefox can require consent for an extension's default-search request; see [Mozilla's manifest documentation](https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/manifest.json/chrome_settings_overrides).
- `containersForce = true` has no effect with the current empty container declaration: the pinned Home Manager module only emits `containers.json` when containers are defined. It is not a current state-overwrite defect.

The pinned Home Manager module also sends `programs.firefox.policies` to macOS defaults independently of `programs.firefox.package`, so using `package = null` does not itself omit policy delivery. Both macOS home builds passed during the Git correction on the same day; no browser launch, profile migration or policy-runtime checks were performed.

The original audited profile had `signon.rememberSignons = false` and standard content blocking. Its user-installed extensions and the owner's final disposition are:

| Extension | ID | Disposition |
| --- | --- | --- |
| Proxy SwitchyOmega | `switchyomega@feliscatus.addons.mozilla.org` | Deferred; skip proxy extensions for now |
| Absolute Enable Right Click & Copy | `{9350bc42-47fb-4598-ae0f-825e3dd9ceba}` | Excluded |
| AdGuard Browser Assistant | `browserassistant@adguard.com` | Excluded |
| React Developer Tools | `@react-devtools` | Added to managed packages |
| Unhook | `myallychou@gmail.com` | Installed; preferences local, no managed-policy support |
| 1Password | `{d634138d-c276-4fc8-924b-40a0ea21d284}` | Installed |
| Wappalyzer | `wappalyzer@crunchlabz.com` | Excluded |
| Refined GitHub | `{a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad}` | Accepted as configured |
| Kagi Search for Firefox | `search@kagi.com` | Installed |
| Kagi Privacy Pass | `privacypass@kagi.com` | Installed |

Names/IDs are inventory evidence, not a guarantee that every extension remains available upstream. Verify availability against the pinned implementation; report any unavailable item rather than silently substituting an extension.

## Work

- Completed in source: introduce a focused Firefox feature, retaining the browser aggregate's inclusion behaviour.
- Use the pinned Home Manager Firefox module where suitable for macOS profiles, preferences and extensions/policies. Reconcile profile paths with the existing installation so activation does not silently select an empty profile.
- Completed: reconcile the original extension inventory with the owner's selected packages. Disabled password saving is already declared. Kagi's extension requests the default-search change; add explicit policy selection only if that behaviour is insufficient.
- Refined GitHub is accepted as configured. Unhook settings remain local because managed policies are unsupported. Proxy extension work is deferred.
- Keep cookies, history, sessions, Sync state, account tokens and generated extension databases local. Document 1Password desktop integration and Kagi login as manual dependencies.

## Acceptance

- A fresh managed profile receives the declared available extensions and selected preferences; existing profile migration is documented.
- The existing Nix-owned update policy survives the refactor.
- Repeated activation preserves browser and extension state outside the declared settings. The existing managed bookmark replacement is explicitly approved by the owner.
- No browser account/session data enters the repository or Nix store.
- Run applicable `just build-home` and `just build-system` checks per [README.md](README.md#validation). Keep verification evidence in this ticket and only necessary manual setup steps in `SETUP.md`; do not switch.

Starting points: the pinned Home Manager `modules/programs/firefox/` sources and [Mozilla policy documentation](https://mozilla.github.io/policy-templates/) (follow its link to the current administrator reference).

Validation after adding React Developer Tools 6.1.1 on 2026-10-22: `just build-home personal hamishwhc` and `just build-home atlassian hcox` passed. No system switch or live browser validation was performed; the extension will be installed on human activation.
