"""Build-time tests use synthetic data and never launch Shottr or call `defaults`."""

import importlib.util
import io
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location("setup_shottr", sys.argv.pop(1))
shottr = importlib.util.module_from_spec(spec)
spec.loader.exec_module(shottr)

DESIRED = {"afterGrabSave": False, "KeyboardShortcuts_area": '{"carbonKeyCode":21}'}


class FakeShottr:
    """Models the app's preference domain and process state."""

    def __init__(self, prefs, running=False, activates=True):
        self.prefs = dict(prefs)
        self.running = running
        self.activates = activates
        self.events = []
        self.urls = []

    def write(self, plist, key, value):
        self.events.append(("write", key, value, self.running))
        self.prefs[key] = value

    def delete(self, plist, key):
        self.events.append(("delete", key))
        del self.prefs[key]

    def quit_app(self):
        self.events.append(("quit",))
        self.running = False

    def launch(self, app):
        self.events.append(("launch",))
        self.running = True

    def open_url(self, url):
        assert self.prefs.get("allowDeeplinks") is True
        self.urls.append(url)
        if self.activates:
            self.prefs["kc-license"] = "encoded"


class SetupTests(unittest.TestCase):
    def setUp(self):
        directory = tempfile.TemporaryDirectory()
        self.addCleanup(directory.cleanup)
        self.plist = Path(directory.name) / "cc.ffitch.shottr.plist"
        self.plist.write_bytes(b"")
        self.secret = Path(directory.name) / "secret"
        self.secret.write_text("abcd-1234 ef/+\n")
        self.output = self.enter(patch.object(sys, "stdout", new_callable=io.StringIO))
        self.enter(patch.object(shottr.time, "sleep"))

    def enter(self, context):
        value = context.__enter__()
        self.addCleanup(context.__exit__, None, None, None)
        return value

    def run_setup(self, app):
        with (
            patch.object(shottr, "read_prefs", side_effect=lambda _: dict(app.prefs)),
            patch.object(shottr, "is_running", side_effect=lambda: app.running),
            patch.object(shottr, "write", side_effect=app.write),
            patch.object(shottr, "delete", side_effect=app.delete),
            patch.object(shottr, "quit_app", side_effect=app.quit_app),
            patch.object(shottr, "launch", side_effect=app.launch),
            patch.object(shottr, "open_url", side_effect=app.open_url),
        ):
            shottr.setup(DESIRED, Path("/Shottr.app"), self.plist, self.secret)

    def test_types_distinguish_bool_from_int(self):
        self.assertEqual(shottr.changes({"a": 1, "b": True}, {"a": True, "b": True}), {"a": True})

    def test_license_requires_nonempty_string(self):
        for prefs in ({}, {"kc-license": ""}, {"kc-license": 1}):
            self.assertFalse(shottr.is_licensed(prefs))
        self.assertTrue(shottr.is_licensed({"kc-license": "x"}))

    def test_blocked_container_is_unavailable_not_unlicensed(self):
        with (
            patch.object(Path, "open", side_effect=PermissionError),
            patch.object(shottr.subprocess, "run") as run,
        ):
            with self.assertRaises(shottr.Unavailable):
                shottr.read_prefs(self.plist)
        run.assert_not_called()

    def test_configured_and_licensed_does_nothing(self):
        app = FakeShottr({**DESIRED, "kc-license": "encoded"}, running=True)
        self.secret.unlink()
        self.run_setup(app)
        self.assertEqual(app.events, [])
        self.assertEqual(self.output.getvalue(), "")

    def test_changes_restart_running_app_before_writing(self):
        app = FakeShottr({"kc-license": "encoded"}, running=True)
        self.run_setup(app)
        self.assertEqual(app.events[0], ("quit",))
        self.assertTrue(all(not running for _, _, _, running in app.events[1:-1]))
        self.assertEqual(app.events[-1], ("launch",))
        self.assertEqual(app.urls, [])

    def test_changes_do_not_launch_stopped_licensed_app(self):
        app = FakeShottr({"kc-license": "encoded"})
        self.run_setup(app)
        self.assertNotIn(("launch",), app.events)

    def test_activation_uses_deep_link_and_restores_permission(self):
        app = FakeShottr(DESIRED)
        self.run_setup(app)
        self.assertEqual(app.urls, ["shottr://settings/license=abcd-1234%20ef%2F%2B"])
        self.assertTrue(shottr.is_licensed(app.prefs))
        self.assertNotIn("allowDeeplinks", app.prefs)
        self.assertNotIn("abcd", self.output.getvalue())
        self.assertIn("license activated", self.output.getvalue())

    def test_existing_deeplink_choice_is_restored(self):
        app = FakeShottr({**DESIRED, "allowDeeplinks": False})
        self.run_setup(app)
        self.assertIs(app.prefs["allowDeeplinks"], False)

    def test_timeout_skips_and_still_restores(self):
        app = FakeShottr(DESIRED, activates=False)
        with patch.object(shottr.time, "monotonic", side_effect=[0, 0, 0, 0, 30]):
            self.run_setup(app)
        self.assertIn("not recorded within 30 seconds", self.output.getvalue())
        self.assertNotIn("allowDeeplinks", app.prefs)

    def test_missing_container_launches_once_then_gives_up(self):
        self.plist.unlink()
        app = FakeShottr({})
        with (
            patch.object(shottr, "launch", side_effect=app.launch) as launch,
            patch.object(shottr.time, "monotonic", side_effect=[0, 15]),
        ):
            with self.assertRaises(shottr.Unavailable):
                shottr.setup(DESIRED, Path("/Shottr.app"), self.plist, self.secret)
        launch.assert_called_once()


if __name__ == "__main__":
    unittest.main()
