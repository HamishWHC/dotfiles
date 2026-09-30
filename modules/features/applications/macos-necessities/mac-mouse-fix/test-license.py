"""Build-time tests use synthetic data and never launch Mac Mouse Fix."""

import importlib.util
import io
from pathlib import Path
import plistlib
import sys
import tempfile
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location("setup_license", sys.argv.pop(1))
license = importlib.util.module_from_spec(spec)
spec.loader.exec_module(license)


class LicenseTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.config = Path(self.directory.name) / "config.plist"
        self.secret = Path(self.directory.name) / "secret"
        self.secret.write_text("synthetic-test-key\n")

    def record_license(self):
        self.config.write_bytes(plistlib.dumps({"License": {
            "licenseStateCache": {
                "___MFPlistCoder_ClassName___": "MFLicenseState",
                "isLicensed": True,
            },
            "licenseStateCacheHash": b"x" * 32,
        }}))

    def test_only_complete_local_cache_counts(self):
        self.assertFalse(license.is_licensed(self.config))
        for data in (b"bad plist", plistlib.dumps([]), plistlib.dumps({
            "License": {"licenseStateCache": {"isLicensed": True}}
        })):
            self.config.write_bytes(data)
            self.assertFalse(license.is_licensed(self.config))
        self.record_license()
        self.assertTrue(license.is_licensed(self.config))

    def test_licensed_skips_secret_and_app_even_without_terminal(self):
        self.record_license()
        self.secret.unlink()
        with patch.object(license.subprocess, "run") as launch:
            license.activate(self.config, self.secret)
        launch.assert_not_called()

    def test_redirected_output_fails_before_secret_or_app(self):
        with (
            patch.object(sys, "stdout", new_callable=io.StringIO) as output,
            patch.object(Path, "read_text") as read_secret,
            patch.object(license.subprocess, "run") as launch,
        ):
            with self.assertRaisesRegex(RuntimeError, "interactive terminal"):
                license.activate(self.config, self.secret)
            read_secret.assert_not_called()
            launch.assert_not_called()
            self.assertEqual(output.getvalue(), "")

    def test_continues_when_activation_is_detected_without_reading_stdin(self):
        with (
            patch.object(sys.stdin, "read", side_effect=AssertionError("must not read stdin")),
            patch.object(sys, "stdout", new_callable=io.StringIO) as output,
            patch.object(output, "isatty", return_value=True),
            patch.object(license.subprocess, "run") as launch,
            patch.object(license.time, "monotonic", return_value=0),
            patch.object(license.time, "sleep", side_effect=lambda _: self.record_license()) as sleep,
        ):
            license.activate(self.config, self.secret)
        sleep.assert_called_once_with(1)
        self.assertEqual(output.getvalue().count("synthetic-test-key"), 1)
        self.assertIn("recorded an active license", output.getvalue())
        launch.assert_called_once_with(
            ["/usr/bin/open", "-b", "com.nuebling.mac-mouse-fix", "macmousefix:activate"],
            check=True,
        )

    def test_timeout_skips_successfully_after_30_seconds(self):
        with (
            patch.object(sys, "stdout", new_callable=io.StringIO) as output,
            patch.object(output, "isatty", return_value=True),
            patch.object(license.subprocess, "run"),
            patch.object(license.time, "monotonic", side_effect=[0, 0, 30]),
            patch.object(license.time, "sleep"),
        ):
            license.activate(self.config, self.secret)
        self.assertIn("timed out after 30 seconds; skipping", output.getvalue())
        self.assertFalse(license.is_licensed(self.config))

    def test_existing_key_can_refresh_cache_without_printing_secret(self):
        with (
            patch.object(sys, "stdout", new_callable=io.StringIO) as output,
            patch.object(output, "isatty", return_value=True),
            patch.object(license.subprocess, "run", side_effect=lambda *a, **k: self.record_license()),
            patch.object(Path, "read_text") as read_secret,
        ):
            license.activate(self.config, self.secret)
        read_secret.assert_not_called()
        self.assertEqual(output.getvalue(), "")


if __name__ == "__main__":
    unittest.main()
