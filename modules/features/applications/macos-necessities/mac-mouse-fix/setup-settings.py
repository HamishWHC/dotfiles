"""Merge declarative preferences without managing Mac Mouse Fix's runtime state."""

import json
import os
import plistlib
import sys
import tempfile
from pathlib import Path


def merge(current, desired):
    for key, value in desired.items():
        if isinstance(value, dict) and isinstance(current.get(key), dict):
            merge(current[key], value)
        else:
            current[key] = value
    return current


def write_atomic(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    descriptor, temporary = tempfile.mkstemp(prefix=f".{path.name}.", dir=path.parent)
    try:
        with os.fdopen(descriptor, "wb") as stream:
            stream.write(data)
        os.replace(temporary, path)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)


def main():
    desired_path, config_path, defaults_path = map(Path, sys.argv[1:4])
    os.umask(0o077)
    desired = json.loads(desired_path.read_text())
    source = config_path if config_path.exists() else defaults_path
    current = plistlib.loads(source.read_bytes())
    updated = merge(current, desired)
    # Read through any existing link, then replace it rather than its target.
    write_atomic(config_path, plistlib.dumps(updated, sort_keys=False))


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, plistlib.InvalidFileException):
        # Config files can contain license caches; do not dump their contents.
        sys.exit("Mac Mouse Fix: could not read, merge or write settings.")
