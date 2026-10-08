"""Reject misleading native build results and exercise the real release compiler."""
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch

from build_native import build
from prepare_native import COMMIT, prepare

ROOT = Path(__file__).resolve().parents[2]


class NativeBoundaryTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.ffi = self.root / "ffi.c"
        self.ffi.write_text("/* no runtime */\n")
        self.compiler = self.root / "compiler"
        self.compiler.write_text(
            '#!/usr/bin/env python3\nimport sys\n'
            f'if "--version" in sys.argv: print("CakeML: {COMMIT}")\n')
        self.compiler.chmod(0o700)
        (self.root / "source.cml").write_text("val x = 1;\n")

    def test_exit_zero_with_empty_assembly_is_rejected(self):
        out = self.root / "output"
        receipt = build(self.root, ["source.cml"], self.compiler, self.ffi, out)
        self.assertEqual(receipt["status"], "SOURCE_REJECTED")
        self.assertNotIn("binary_sha256", receipt)
        with self.assertRaises(FileExistsError):
            build(self.root, ["source.cml"], self.compiler, self.ffi, out)

    def test_foreign_pin_and_version_timeout_are_retained(self):
        with patch("build_native.subprocess.run", return_value=
                   subprocess.CompletedProcess([], 0, "CakeML: foreign\n")):
            receipt = build(self.root, ["source.cml"], self.compiler, self.ffi,
                            self.root / "foreign")
        self.assertEqual(receipt["status"], "COMPILER_PIN_REJECTED")
        with patch("build_native.subprocess.run", side_effect=
                   subprocess.TimeoutExpired("compiler", 30)):
            out = self.root / "timeout"
            build(self.root, ["source.cml"], self.compiler, self.ffi, out)
        self.assertEqual(json.loads((out / "receipt.json").read_text())["status"],
                         "VERSION_TIMEOUT")

    def test_release_digest_rejected_before_extracting_or_running(self):
        archive = self.root / "release.tar.gz"
        archive.write_bytes(b"foreign release")
        out = self.root / "release"
        with self.assertRaisesRegex(ValueError, "digest mismatch"):
            prepare(archive, out)
        self.assertFalse(out.exists())


@unittest.skipUnless(os.environ.get("HOL4_CAKEML_NATIVE") and
                     os.environ.get("HOL4_CAKEML_FFI"), "native CakeML paths unset")
class NativeCompilerTests(unittest.TestCase):
    def test_real_fixture_executes_and_untranslated_kernel_is_rejected(self):
        with tempfile.TemporaryDirectory() as tmp:
            out = Path(tmp)
            compiler = Path(os.environ["HOL4_CAKEML_NATIVE"])
            ffi = Path(os.environ["HOL4_CAKEML_FFI"])
            fixture = out / "fixture"
            receipt = build(ROOT, ["tools/cakeml-hol4/fixtures/native-result.cml"],
                            compiler, ffi, fixture)
            self.assertEqual(receipt["status"], "NATIVE_COMPILED_UNQUALIFIED")
            env = dict(os.environ, CML_HEAP_SIZE="256", CML_STACK_SIZE="32")
            result = subprocess.run([str(fixture / "program")], text=True,
                                    capture_output=True, env=env, timeout=30)
            self.assertEqual((result.returncode, result.stdout), (0, "20\n"))
            kernel = out / "kernel"
            receipt = build(ROOT, ["src/0/KernelTypes.sml"], compiler, ffi, kernel)
            self.assertEqual(receipt["status"], "SOURCE_REJECTED")
            self.assertIn("Parsing failed", (kernel / "compiler.log").read_text())
            self.assertNotIn("binary_sha256", receipt)


if __name__ == "__main__":
    unittest.main()
