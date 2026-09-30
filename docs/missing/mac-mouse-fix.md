# Mac Mouse Fix: settings and license

Status: Settings and interactive license setup implemented. Home Manager opens the native license dialog when no local activation is recorded and waits up to 30 seconds before continuing. Mac Mouse Fix 3.0.8 requires its own signed app to import the key into Keychain.

## Settings

[The Home Manager module](../../modules/features/applications/macos-necessities/mac-mouse-fix/default.nix) manages the preferences in [settings.json](../../modules/features/applications/macos-necessities/mac-mouse-fix/settings.json). They preserve the previously configured button 4/5 mappings, scrolling, pointer behavior, hidden menu item and disabled update checks. `State.remapsAreInitialized` prevents the app from replacing the declared remaps with first-launch defaults.

Activation merges these settings into a regular, writable `~/Library/Application Support/com.nuebling.mac-mouse-fix/config.plist` with mode `0600`. It recursively overlays the declared preferences, replaces arrays such as remaps, and preserves all other fields, including license caches, launch counters and device/app overrides. There is no separate settings state file. Removing a preference from the declaration leaves its current value in the app's settings.

If the existing plist is a symlink, activation reads its contents and atomically replaces the link with the merged regular file, leaving the target untouched. Only a missing configuration starts from the installed app's `Contents/Resources/default_config.plist`. This runs before Home Manager removes obsolete file links. Normal app upgrades retain responsibility for config-schema migrations.

Mac Mouse Fix 3.0.8 disables its file watcher. After running the settings script, the Nix activation hook runs a small native helper that sends the app's `configFileChanged` message to running app/helper processes. Stopped processes read the file on their next launch. License setup can open the app; Accessibility approval and initial background-service enablement remain necessary manual setup.

## License

Home Manager SOPS decrypts the existing `mac_mouse_fix_license_key` from `secrets/default.yaml`, mode `0400`. No license value is evaluated into the Nix store. There is no separate license enable option.

After merging settings, file linking and synchronous SOPS decryption, activation runs `setup-license.py` directly with the config and SOPS secret paths. The script reads the app's local `License.licenseStateCache` and requires a licensed `MFLicenseState` with an accompanying 32-byte hash. If activation is already recorded, it exits without reading the secret or opening the app.

Otherwise, stdout must be a terminal. The script opens `macmousefix:activate` and checks the cache again. If activation is still not recorded, it prints the SOPS key to stdout, instructs the user to paste it into the app and click **Activate License**, and polls the app's recorded status for up to 30 seconds. It continues automatically when activation is detected. On timeout it reports that license setup was skipped and returns successfully, allowing the rest of activation to continue. No terminal input is read. Redirected output is rejected before reading the key or opening the app.

This reads cached status, not an independent proof of current Keychain/server validity: an existing cache, including one preserved from the former symlink, can remain stale until the app validates it. The hook never manufactures license state, verifies a license with the vendor itself, or writes Keychain data. Native activation performs validation and stores the real key.

A read-only `security find-generic-password -l com.nuebling.mac-mouse-fix.secure-storage` query on this Mac returned item-not-found. That cannot establish absence from the app-restricted iCloud Keychain. Item presence would not establish activation anyway: [`TrialCounter.swift`](https://github.com/noah-nuebling/mac-mouse-fix/blob/3.0.8/Shared/License/TrialCounter.swift) stores trial usage in the same secure-storage dictionary before activation.

Source inspection of tag **3.0.8**, commit `7969b9beda5c60c92649e57fa3017397d7de7463`, established the limitation:

- [`SecureStorage.swift`](https://github.com/noah-nuebling/mac-mouse-fix/blob/3.0.8/Shared/Config/SecureStorage/SecureStorage.swift) stores `License.key` in a keyed archive inside the synchronizable Keychain item labeled `com.nuebling.mac-mouse-fix.secure-storage`.
- [The app's entitlements](https://github.com/noah-nuebling/mac-mouse-fix/blob/3.0.8/App/SupportFiles/App.entitlements) restrict sharing to its signing team's Keychain access group. Read-only inspection of the installed arm64 app and helper confirms `LM5Z78756B.com.nuebling.mac-mouse-fix.keychain-group`. Apple's [Keychain access-group documentation](https://developer.apple.com/documentation/security/ksecattraccessgroup) explains that this applies when `kSecAttrSynchronizable` is true. Creating a generic password with the same label from a Nix helper does not populate that group. Running as root does not supply the required validated signing entitlement.
- [`AppDelegate.m`](https://github.com/noah-nuebling/mac-mouse-fix/blob/3.0.8/App/AppDelegate.m) handles `macmousefix:activate` by opening the license sheet; it has no key-import parameter. The app entry point and message-port handlers expose no unattended license-import command.
- [`GetLicenseState.swift`](https://github.com/noah-nuebling/mac-mouse-fix/blob/3.0.8/Shared/License/Retrieve/GetLicenseState.swift) validates the cached license against both the real Keychain key and device identity. Preserving cached `isLicensed` state does not itself activate the app.
- [`MFMessagePort.m`](https://github.com/noah-nuebling/mac-mouse-fix/blob/3.0.8/Shared/MessagePort/MFMessagePort.m) and [`Config.m`](https://github.com/noah-nuebling/mac-mouse-fix/blob/3.0.8/Shared/Config/Config.m) define the settings reload protocol and confirm that the file watcher is disabled.

## Validation

- Validated with `just build-home personal` and `just build-system personal`; both passed, including the build-time regression tests.
- Build-time regression checks cover preserving existing license/runtime state, repeat merges and merging a symlink's contents without modifying its target. License tests use synthetic data to cover incomplete caches, already-activated skipping, redirected-output secret protection, native cache refresh, automatic continuation after activation and successful skipping on timeout.
- No system switch, app launch, Keychain mutation or real activation has been performed by the agent. Runtime reload and native license activation remain unverified.

`SETUP.md` contains only the remaining manual permission/enablement actions; the activation hook supplies license instructions at the point of use.
