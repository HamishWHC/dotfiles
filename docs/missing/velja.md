# Velja: available browser list

Status: Implemented and build-validated for both macOS hosts; human activation remains. Priority: Normal.

## Current state

[velja.nix](../../modules/features/applications/browsers/velja.nix) owns the App Store installation and the available browser list through `system.defaults.CustomUserPreferences`. Browser order is Firefox, Chromium, Safari, Firefox (Private). Current default browser, rules, profiles, tracking preferences and sandbox bookmarks remain local.

## Work

### Owner decisions, 2026-10-22

- Manage the available browsers in this exact order: Firefox, Chromium, Safari, Firefox (Private).
- Use Nix's defaults support (`system.defaults.CustomUserPreferences`), not handwritten defaults command scripts.
- Leave the current default browser under user control. Do not declare `defaultBrowser` or change the system default browser automatically.
- Leave rules and profiles local. The owner does not customize rules; rule import and profile integration are no longer required.
- After the owner granted filesystem privacy access, the local plist confirmed `preferredBrowsers` is an array of strings with the exact declared canonical identifiers. No inference from URL-scheme syntax was needed.

### Assessment, 2026-10-22

- Installed version: 3.2.4. [Upstream documents](https://sindresorhus.com/velja#scripting) selective `defaults write com.sindresorhus.Velja defaultBrowser <bundle-id>` and the equivalent `alternativeBrowser` key. `com.sindresorhus.Velja.promptMarker` selects the browser prompt. This is a concrete automation path for browser choices.
- Rules have a supported export/import UI at the bottom of Settings → Rules. No unattended rule-import interface was found in the published scripting documentation. This is now outside the requested scope.
- Current upstream documentation supports only new-style Firefox profiles, whereas this repository explicitly enables Firefox legacy profiles. Routing to the Firefox application is the appropriate baseline; do not promise routing to the managed `Personal` profile through Velja's profile integration.
- Browser-profile folder access and macOS default-browser selection remain separate setup concerns. Preserve sandbox bookmarks and browser identities.
- Direct reads initially failed because of macOS privacy access. After the owner granted access, `~/Library/Containers/com.sindresorhus.Velja/Data/Library/Preferences/com.sindresorhus.Velja.plist` was readable. It already contained the requested four-entry list. No live preferences were changed.

### Implementation and activation

- The focused feature uses native nix-darwin defaults support, which generates writes for individual top-level preference keys. No custom defaults script or whole-plist replacement was added.
- Removing the list declaration leaves its existing value untouched.
- Preserve sandbox bookmarks, runtime logs and local account state. App Store purchase/account restoration remains local.
- Document default-browser selection and launch-at-login steps where macOS requires user interaction.

## Acceptance

- The available browser list has the requested four entries and order.
- Current default browser, rules, profiles and unrelated preferences stay local.
- Use bundle identities rather than machine-specific browser paths.
- Validate with applicable `just build-home` / `just build-system` checks; leave routing checks after switching to the human.

Starting point: [Velja's documentation and scripting support](https://sindresorhus.com/velja).

## Validation, 2026-10-22

`just build-system personal` and `just build-system atlassian` passed with the declared browser list. `just build-home personal hamishwhc` and `just build-home atlassian hcox` also passed for the shared utility changes. No switch or live preference write was performed. The human can switch and reopen Velja to apply the list; the current default browser remains unmanaged.
