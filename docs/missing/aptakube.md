# Aptakube: SOPS-managed license only

Status: Implemented in Home Manager; both macOS home and system builds passed. Live activation awaits a human system switch and app launch. Linux deliberately throws until its license path is established.

## Implementation

[aptakube/default.nix](../../modules/features/applications/aptakube/default.nix) installs the application and always provisions its license through Home Manager. Both macOS hosts include this feature for the owner's two-device key. There is no separate license option: hosts that should not use the license must omit the Aptakube feature. The Linux application package remains declared, but evaluation of license setup throws an explicit error until the Linux license path is known.

The authoritative secret is the owner-provided `aptakube_license_key` in `secrets/default.yaml`. Keep this original key as the sole encrypted input; do not save token snapshots or copies of `license.bin` in SOPS. The owner confirms a two-device allowance. Subscription versus legacy perpetual purchase has not been established, and provisioning does not depend on that distinction.

[secrets.nix](../../modules/features/secrets.nix) imports `inputs.sops-nix.homeManagerModules.sops` and configures the shared encrypted file and the user's age key. It retains the existing system-level GitHub token declaration. Home Manager exposes the Aptakube secret through `config.sops.secrets.aptakube-license-key.path` in the user's SOPS directory.

Home Manager activation runs [setup-license.sh](../../modules/features/applications/aptakube/setup-license.sh) after the `sops-nix` activation entry. On macOS, the shared secrets module runs the upstream-generated decryption script synchronously with its configured environment, before Home Manager installs launch agents. This replaces upstream's asynchronous bootstrap activation so downstream entries receive the current secret. The SOPS login agent still restores temporary secrets after reboot. Linux retains the upstream systemd integration.

The setup script provisions `~/Library/Application Support/com.aptakube.Aptakube/license.bin` as JSON containing the key and an initially empty `token`. Aptakube obtains and writes its own token through its normal online license validation on first launch. No manual key entry is required. The initial launch needs access to Aptakube's license server; Nix builds and activation make no licensing requests.

The application directory is mode `0700`, the mutable license file is `0600`, and the runtime SOPS secret is `0400`. JSON is generated from the secret file at runtime, with no plaintext key in Nix outputs, command arguments or logs. A temporary file in the destination directory is renamed atomically into place. Symlink destinations are rejected.

When the existing license contains the same key and a string token, provisioning preserves its contents, including tokens refreshed by Aptakube. Missing or malformed license files are recreated; changing the encrypted key replaces the license with the new key and an empty token. Aptakube reads that key on its next launch. Repeated Nix activation does not contact the license server or register devices. Removing the Aptakube feature stops provisioning and secret delivery without deleting local application state or remotely revoking a device.

`preferences.json`, kubeconfigs, cluster selection and all other Aptakube settings remain local. `SETUP.md` retains general secret onboarding and no longer instructs the owner to activate Aptakube manually. Validation and implementation details belong here, not in the setup guide.

## Interface evidence

Read-only inspection of installed Aptakube **1.19.7** on 2026-09-22 established:

- `license.bin` is JSON with two string fields, `license_key` and `token`.
- The cached token is a JWT with `license_key`, `expiry_date`, `iat`, `iss` and `exp` claims. No device identifier appears in those claims. This alone does not establish token portability, so the implementation does not copy the token between devices.
- The license reader requires both JSON fields. If token decoding fails or the token expires, it retains the key and returns no cached license. The normal `check_license` handler then calls the same online validation path used for key entry, `/api/v1/license/validate`, and saves the returned token.
- Specifically, in the installed arm64 binary, the reader at `0x1005230d0` returns the retained key at `0x1005237d0` after a token decode error. The `check_license` handler branches at `0x100432860` / `0x100432870` to online validation through `0x1004330b8` and `0x100523e4c`. These are version-specific investigation notes, not runtime dependencies.

This uses the installed application's file reader and renewal behavior, not a publicly documented deployment CLI. The app still validates the real entitlement with its server; no token or licensed flag is fabricated. Runtime confirmation remains outstanding, and a build alone does not demonstrate successful activation.

## Validation

- Passed after refactoring on 2026-09-22: `just build-home personal`, `just build-system personal`, `just build-home atlassian hcox` and `just build-system atlassian`. The home builds include ShellCheck for the license setup script.
- Reviewed both generated Home Manager activation scripts: synchronous user SOPS decryption precedes license setup, which uses the host's user secret path and home directory. Launch-agent installation follows.
- No system switch, application launch or live license mutation was performed by the agent.

References: [license management](https://aptakube.com/license-manager), [current license offerings](https://aptakube.com/pricing), [sops-nix Home Manager integration](https://github.com/Mic92/sops-nix#use-with-home-manager).
