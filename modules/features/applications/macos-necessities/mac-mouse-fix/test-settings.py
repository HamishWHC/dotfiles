"""Build-time regression checks; no app, real user config or secrets are used."""

import importlib.util
import json
from pathlib import Path
import plistlib
import sys
import tempfile
import unittest
from unittest.mock import patch

sys.dont_write_bytecode = True
spec = importlib.util.spec_from_file_location("settings", sys.argv.pop(1))
settings = importlib.util.module_from_spec(spec)
spec.loader.exec_module(settings)


class SettingsTests(unittest.TestCase):
    def test_preferences_preserve_license_and_unmanaged_state(self):
        original = {
            "License": {"licenseStateCacheHash": b"local-cache"},
            "State": {"launchesOverall": 42},
            "General": {"showMenuBarItem": True, "futureSetting": "local"},
            "AppOverrides": {"example": {"Scroll": {"speed": "low"}}},
        }
        result = settings.merge(original, {"General": {"showMenuBarItem": False}})
        self.assertFalse(result["General"]["showMenuBarItem"])
        self.assertEqual(result["General"]["futureSetting"], "local")
        self.assertEqual(result["License"], {"licenseStateCacheHash": b"local-cache"})
        self.assertEqual(result["State"], {"launchesOverall": 42})
        self.assertEqual(result["AppOverrides"], {"example": {"Scroll": {"speed": "low"}}})

    def test_remaps_replace_as_a_unit_and_reapplication_is_idempotent(self):
        old = {"Remaps": [{"trigger": "old"}]}
        desired = {"Remaps": [{"trigger": "new", "modifiers": {}}],
                   "State": {"remapsAreInitialized": True}}
        result = settings.merge(old, desired)
        self.assertEqual(result, desired)
        self.assertEqual(settings.merge(result, desired), desired)

    def test_setup_merges_linked_settings_and_replaces_only_the_link(self):
        with tempfile.TemporaryDirectory() as directory:
            target = Path(directory) / "old-store-config"
            original = plistlib.dumps({"General": {"showMenuBarItem": True},
                                      "State": {"launchesOverall": 42}})
            target.write_bytes(original)
            destination = Path(directory) / "config.plist"
            destination.symlink_to(target)
            desired = Path(directory) / "settings.json"
            desired.write_text(json.dumps({"General": {"showMenuBarItem": False}}))
            with patch.object(sys, "argv", ["setup-settings.py", str(desired),
                                            str(destination), "unused-defaults"]):
                settings.main()
            self.assertFalse(destination.is_symlink())
            self.assertEqual(plistlib.loads(destination.read_bytes()), {
                "General": {"showMenuBarItem": False}, "State": {"launchesOverall": 42},
            })
            self.assertEqual(target.read_bytes(), original)
            self.assertEqual(destination.stat().st_mode & 0o777, 0o600)


unittest.main()
