"""Guide native activation, using the license status last recorded by the app."""

import plistlib
import subprocess
import sys
import time
from pathlib import Path


def is_licensed(config_path):
    try:
        config = plistlib.loads(config_path.read_bytes())
    except (FileNotFoundError, ValueError, plistlib.InvalidFileException):
        return False
    if not isinstance(config, dict):
        return False
    license_info = config.get("License", {})
    if not isinstance(license_info, dict):
        return False
    cache = license_info.get("licenseStateCache", {})
    cache_hash = license_info.get("licenseStateCacheHash")
    # This is the app's cached status, not an independent Keychain/server check.
    # Only the app writes these fields and validates the key and device hash.
    return (
        isinstance(cache, dict)
        and cache.get("___MFPlistCoder_ClassName___") == "MFLicenseState"
        and cache.get("isLicensed") == 1
        and isinstance(cache_hash, bytes)
        and len(cache_hash) == 32
    )


def wait_for_license(config_path):
    deadline = time.monotonic() + 30
    while not is_licensed(config_path):
        remaining = deadline - time.monotonic()
        if remaining <= 0:
            return False
        time.sleep(min(1, remaining))
    return True


def activate(config_path, secret_path):
    if is_licensed(config_path):
        return

    # Check before reading the secret so redirected output cannot log the key.
    if not sys.stdout.isatty():
        raise RuntimeError(
            "native license activation needs an interactive terminal; "
            "rerun activation there without redirecting stdout"
        )

    subprocess.run(
        ["/usr/bin/open", "-b", "com.nuebling.mac-mouse-fix", "macmousefix:activate"],
        check=True,
    )
    if is_licensed(config_path):
        return

    key = secret_path.read_text().strip()
    if not key:
        raise RuntimeError("the license secret is empty")
    print(f"\nMac Mouse Fix license key:\n{key}\n", flush=True)
    del key
    print(
        "Paste the key into Mac Mouse Fix and click Activate License.\n"
        "Waiting up to 30 seconds for activation...",
        flush=True,
    )
    if wait_for_license(config_path):
        print("Mac Mouse Fix has recorded an active license. Continuing activation.")
    else:
        print(
            "Mac Mouse Fix: activation timed out after 30 seconds; skipping license setup."
        )


if __name__ == "__main__":
    try:
        activate(Path(sys.argv[1]), Path(sys.argv[2]))
    except RuntimeError as error:
        sys.exit(f"Mac Mouse Fix: {error}.")
    except (OSError, UnicodeError, subprocess.CalledProcessError):
        sys.exit("Mac Mouse Fix: could not read license state/secret or open the app.")
    except KeyboardInterrupt:
        sys.exit("\nMac Mouse Fix: activation cancelled.")
