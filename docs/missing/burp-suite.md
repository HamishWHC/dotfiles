# Burp Suite: preferences and CA trust in macOS Keychain

Status: Open. Priority: High. Dependencies: An identified Burp CA certificate; coordinate proxy profile naming with [SwitchyOmega](proxy-switchyomega.md).

## Current state

[cybersec.nix](../../modules/features/applications/cybersec.nix) installs the Burp Suite Community cask. No Burp preferences or CA trust setup is managed. The owner specifically wants Nix to install Burp's certificate into Keychain if feasible.

## Work

- Add a focused Burp feature without changing Wireshark or Ghidra configuration.
- Capture selected reusable user settings, proxy listener choices and extension setup where supported. Keep target-specific projects, captured traffic and session data local.
- Establish the CA source. Burp creates a CA per installation; trusting a certificate unrelated to the active Burp CA will not work. Prefer a host-local exported public certificate as input unless the owner explicitly chooses a shared CA identity.
- Implement conditional, repeat-safe macOS Keychain import and appropriate TLS trust for that certificate. Inspect pinned nix-darwin certificate options first; if a supported activation hook is needed, distinguish login versus system Keychain and use the intended user's context.
- Identify the managed certificate by fingerprint, not merely the generic `PortSwigger CA` name. Handle missing source, rotation, repeated activation and removal without touching unrelated trusted certificates. Do not fetch and trust an arbitrary certificate from a localhost proxy during activation.
- Keep any CA private key local by default. If shared CA material is deliberately introduced, put private material in SOPS and provision only at runtime. Keychain trust requires only the public certificate.
- Explain the scope of Keychain trust and whether Firefox additionally needs its own CA import or enterprise-root integration. Coordinate any Firefox-specific change with its ticket; Keychain import alone is not proof that all browsers trust the CA.

## Acceptance

- A configured CA input results in the correct managed Keychain certificate/trust through the system configuration.
- Repeated activation does not duplicate certificates, and rotation/removal has a precise documented policy.
- No Burp private key or captured traffic is published or put in the Nix store.
- `SETUP.md` covers initial CA export/selection, any unavoidable trust prompt, and a human browser check against the actual Burp instance.
- Only use the allowed [home/system builds](README.md#validation). The implementing agent must not switch, import live certificates, or change live trust to verify the ticket.

References: [Burp CA installation](https://portswigger.net/burp/documentation/desktop/external-browser-config/certificate), [Burp CA management](https://portswigger.net/burp/documentation/desktop/tools/proxy/manage-certificates).
