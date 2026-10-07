"""Regression tests for accepting report and proof artifact identities."""
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

from audit_reports import HERE, audit
from proof_bundle import build, verify


class EvidenceTests(unittest.TestCase):
    def test_changed_report_bytes_are_rejected_before_source_lookup(self):
        # Self-contained fixture; the original archives await workspace recovery.
        with tempfile.TemporaryDirectory() as td:
            inputs = Path(td) / "input"
            machine = inputs / "machine"
            machine.mkdir(parents=True)
            raw = b"{}"
            (machine / "MANIFEST.json").write_text(json.dumps({"files": [
                {"name": "report.json", "bytes": len(raw),
                 "sha256": hashlib.sha256(raw).hexdigest()}]}))
            (machine / "report.json").write_bytes(raw + b"\n")
            with self.assertRaisesRegex(ValueError, "report identity mismatch"):
                audit(inputs, {})

    def test_changed_artifact_bytes_are_rejected(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            artifact = root / "code.S"
            artifact.write_text("original")
            manifest = root / "bundle.json"
            build(root, "Macro.correct", ["code.S"], manifest)
            verify(root, manifest)
            artifact.write_text("tampered")
            with self.assertRaisesRegex(ValueError, "identity mismatch"):
                verify(root, manifest)

    def test_symlink_and_empty_bundle_are_rejected(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            (root / "code.S").write_text("code")
            (root / "link.S").symlink_to(root / "code.S")
            for artifacts, error in [(["link.S"], "symlink"), ([], "contain artifacts")]:
                with self.subTest(artifacts=artifacts), self.assertRaisesRegex(ValueError, error):
                    build(root, "Macro.correct", artifacts, root / "bundle.json")

    def test_tampered_bundle_does_not_execute_either_binary_or_retain_receipt(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            (root / "code.S").write_text("code")
            manifest = root / "bundle.json"
            build(root, "Macro.correct", ["code.S"], manifest)
            (root / "code.S").write_text("modified")
            marker = root / "executed"
            binaries = []
            for name in ["ordinary", "cakeml"]:
                binary = root / name
                binary.write_text(f'#!/bin/sh\n# {name}\ntouch "{marker}"\n')
                binary.chmod(0o755)
                binaries.append(binary)
            receipt = root / "receipt.json"
            receipt.write_text('{"status":"old success"}')
            cp = subprocess.run([sys.executable, str(HERE / "dual_replay.py"),
                "--bundle-root", str(root), "--manifest", str(manifest),
                "--replay-script", str(root / "unused.sml"),
                "--original-hol", str(binaries[0]), "--cakeml-hol", str(binaries[1]),
                "--receipt", str(receipt)], capture_output=True, text=True)
            self.assertEqual(cp.returncode, 2, cp.stdout + cp.stderr)
            self.assertIn("identity mismatch", cp.stdout)
            self.assertFalse(marker.exists())
            self.assertFalse(receipt.exists())


if __name__ == "__main__":
    unittest.main()
