"""Apply selected Shottr preferences and activate its license through the app's deep link.

Shottr is sandboxed, so its preferences live in its container. Writes go through
`defaults` (and therefore cfprefsd) so they stay coherent with the app's own cache.
"""

import json
import os
import plistlib
import subprocess
import sys
import time
from pathlib import Path
from urllib.parse import quote

BUNDLE_ID = "cc.ffitch.shottr"
# Undocumented: Shottr fills its license field with the value and runs Activate.
LICENSE_URL = "shottr://settings/license="
DEEPLINKS_KEY = "allowDeeplinks"


class Unavailable(Exception):
    """Shottr's state cannot be inspected; skip rather than guess."""


def container_plist(home):
    return home / f"Library/Containers/{BUNDLE_ID}/Data/Library/Preferences/{BUNDLE_ID}.plist"


def domain(plist):
    return str(plist.with_suffix(""))


def read_prefs(plist):
    # Probe the file first: when macOS blocks container access, `defaults`
    # silently returns an empty domain, which would look unlicensed.
    try:
        with plist.open("rb"):
            pass
    except PermissionError:
        raise Unavailable(
            "macOS blocked access to Shottr's container; allow your terminal to "
            "access data from other apps, then rerun activation"
        ) from None
    exported = subprocess.run(
        ["/usr/bin/defaults", "export", domain(plist), "-"],
        capture_output=True,
        check=True,
    ).stdout
    prefs = plistlib.loads(exported)
    if not isinstance(prefs, dict):
        raise Unavailable("Shottr's preferences are not a dictionary")
    return prefs


def is_licensed(prefs):
    # Shottr stores this only after a successful activation and removes it when
    # the license is removed. Its value is encoded license data; never print it.
    value = prefs.get("kc-license")
    return isinstance(value, str) and bool(value)


def changes(prefs, desired):
    # Compare types too: plist booleans and integers are distinct, but True == 1.
    return {
        key: value
        for key, value in desired.items()
        if type(prefs.get(key)) is not type(value) or prefs.get(key) != value
    }


def write(plist, key, value):
    if isinstance(value, bool):
        typed = ["-bool", "true" if value else "false"]
    elif isinstance(value, int):
        typed = ["-int", str(value)]
    elif isinstance(value, float):
        typed = ["-float", repr(value)]
    elif isinstance(value, str):
        typed = ["-string", value]
    else:
        raise ValueError(f"unsupported preference type for {key}")
    subprocess.run(["/usr/bin/defaults", "write", domain(plist), key, *typed], check=True)


def delete(plist, key):
    subprocess.run(
        ["/usr/bin/defaults", "delete", domain(plist), key],
        check=True,
        capture_output=True,
    )


def is_running():
    return (
        subprocess.run(
            ["/usr/bin/pgrep", "-qxU", str(os.getuid()), "Shottr"], check=False
        ).returncode
        == 0
    )


def quit_app():
    subprocess.run(
        [
            "/usr/bin/osascript",
            "-l",
            "JavaScript",
            "-e",
            'ObjC.import("AppKit");'
            f'$.NSRunningApplication.runningApplicationsWithBundleIdentifier("{BUNDLE_ID}")'
            ".js.forEach(app => app.terminate);",
        ],
        check=True,
        capture_output=True,
    )
    if not wait_for(lambda: not is_running(), 10):
        raise RuntimeError("Shottr did not quit within 10 seconds")


def launch(app):
    subprocess.run(["/usr/bin/open", "-g", "-j", str(app)], check=True)


def open_url(url):
    # Pass the URL on stdin so the license key never appears in process arguments.
    subprocess.run(
        [
            "/usr/bin/osascript",
            "-l",
            "JavaScript",
            "-e",
            'ObjC.import("AppKit");'
            "const data = $.NSFileHandle.fileHandleWithStandardInput.readDataToEndOfFile;"
            "const url = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding);"
            "$.NSWorkspace.sharedWorkspace.openURL($.NSURL.URLWithString(url)) ? '' : 'failed';",
        ],
        input=url.encode(),
        check=True,
        capture_output=True,
    )


def wait_for(predicate, seconds):
    deadline = time.monotonic() + seconds
    while not predicate():
        remaining = deadline - time.monotonic()
        if remaining <= 0:
            return False
        time.sleep(min(1, remaining))
    return True


def setup(desired, app, plist, secret):
    if not plist.exists():
        # The container appears on first launch; settings and activation need it.
        launch(app)
        if not wait_for(plist.exists, 15):
            raise Unavailable("Shottr has not created its preferences yet; open it once, then rerun activation")

    prefs = read_prefs(plist)
    licensed = is_licensed(prefs)
    pending = changes(prefs, desired)
    restore_deeplinks = None
    if not licensed and prefs.get(DEEPLINKS_KEY) is not True:
        # Allow deep links only while activating, then restore the user's choice.
        pending[DEEPLINKS_KEY] = True
        restore_deeplinks = (DEEPLINKS_KEY in prefs, prefs.get(DEEPLINKS_KEY))

    try:
        if pending:
            # Shottr reads hotkeys and deep link permission at launch, so restart it.
            was_running = is_running()
            if was_running:
                quit_app()
            for key, value in pending.items():
                write(plist, key, value)
            if was_running or not licensed:
                launch(app)
        if licensed:
            return

        key = secret.read_text().strip()
        if not key:
            raise RuntimeError("the license secret is empty")
        if not wait_for(is_running, 15):
            raise RuntimeError("Shottr did not start within 15 seconds")
        open_url(LICENSE_URL + quote(key, safe=""))
        del key
        print("Shottr: activating license, waiting up to 30 seconds...", flush=True)
        if wait_for(lambda: is_licensed(read_prefs(plist)), 30):
            print("Shottr: license activated.")
        else:
            print("Shottr: activation was not recorded within 30 seconds; skipping license setup.")
    finally:
        if restore_deeplinks is not None:
            existed, value = restore_deeplinks
            if existed:
                write(plist, DEEPLINKS_KEY, value)
            else:
                delete(plist, DEEPLINKS_KEY)


def main():
    desired_path, app, home, secret = map(Path, sys.argv[1:5])
    desired = json.loads(desired_path.read_text())
    setup(desired, app, container_plist(home), secret)


if __name__ == "__main__":
    try:
        main()
    except Unavailable as error:
        print(f"Shottr: {error}; skipping setup.", file=sys.stderr)
    except RuntimeError as error:
        sys.exit(f"Shottr: {error}.")
    except (OSError, ValueError, UnicodeError, plistlib.InvalidFileException, subprocess.CalledProcessError):
        # Preferences contain license data; do not dump them or command output.
        sys.exit("Shottr: could not read or update preferences, read the license secret or open the app.")
    except KeyboardInterrupt:
        sys.exit("\nShottr: setup cancelled.")
