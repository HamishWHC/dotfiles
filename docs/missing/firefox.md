# Firefox: profiles, extensions and portable preferences

Status: Open. Priority: High. Dependencies: None. Coordinate the profile contract with [Proxy SwitchyOmega](proxy-switchyomega.md).

## Current state

[browsers.nix](../../modules/features/applications/browsers.nix) installs Firefox and already sets `extraPolicies.DisableAppUpdate = true`. Preserve that update policy. Profiles, extensions and portable preferences are not managed.

The audited profile had `signon.rememberSignons = false` and standard content blocking. Its user-installed extensions were:

| Extension | ID |
| --- | --- |
| Proxy SwitchyOmega | `switchyomega@feliscatus.addons.mozilla.org` |
| Absolute Enable Right Click & Copy | `{9350bc42-47fb-4598-ae0f-825e3dd9ceba}` |
| AdGuard Browser Assistant | `browserassistant@adguard.com` |
| React Developer Tools | `@react-devtools` |
| Unhook | `myallychou@gmail.com` |
| 1Password | `{d634138d-c276-4fc8-924b-40a0ea21d284}` |
| Wappalyzer | `wappalyzer@crunchlabz.com` |
| Refined GitHub | `{a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad}` |
| Kagi Search for Firefox | `search@kagi.com` |
| Kagi Privacy Pass | `privacypass@kagi.com` |

Names/IDs are inventory evidence, not a guarantee that every extension remains available upstream. Verify availability against the pinned implementation; report any unavailable item rather than silently substituting an extension.

## Work

- Introduce a focused Firefox feature, retaining the browser aggregate's inclusion behaviour.
- Use the pinned Home Manager Firefox module where suitable for macOS profiles, preferences and extensions/policies. Reconcile profile paths with the existing installation so activation does not silently select an empty profile.
- Declare the extension inventory and selected portable preferences, including disabled password saving. Capture the actual search-engine choice rather than infer it solely from the Kagi extension.
- Capture useful extension settings (for example Unhook and Refined GitHub) only where the extension supports a repeatable import or managed setting. SwitchyOmega has its own ticket.
- Keep cookies, history, sessions, Sync state, account tokens and generated extension databases local. Document 1Password/AdGuard desktop integration and Kagi login as manual dependencies.
- Give the SwitchyOmega ticket a stable profile/extension integration point; avoid two modules competing for `profiles.ini` or browser policies.

## Acceptance

- A fresh managed profile receives the declared available extensions and selected preferences; existing profile migration is documented.
- The existing Nix-owned update policy survives the refactor.
- Repeated activation preserves browser and extension state outside the declared settings.
- No browser account/session data enters the repository or Nix store.
- Run applicable `just build-home` and `just build-system` checks per [README.md](README.md#validation). Record human profile, extension and login checks in `SETUP.md`; do not switch.

Starting points: the pinned Home Manager `modules/programs/firefox/` sources and [Mozilla policy documentation](https://mozilla.github.io/policy-templates/) (follow its link to the current administrator reference).
