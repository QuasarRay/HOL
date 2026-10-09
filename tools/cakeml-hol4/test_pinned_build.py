"""A failed host proof build must stop before linking or claiming success."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch

import recover_pinned_links


class PinnedBuildBoundaryTests(unittest.TestCase):
    def test_invalid_compiler_budget_is_rejected_before_any_build(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            for budget in ["0", "-1", "900; touch marker", "21601", "0001"]:
                out = root / "evidence"
                env = dict(os.environ, HOLDIR=str(root), CAKEMLDIR=str(root),
                           HOL4_PINNED_COMPILER_OUT=str(out),
                           HOL4_PINNED_COMPILER_SECONDS=budget)
                script = Path(__file__).with_name("build_pinned_compiler.sh")
                result = subprocess.run(["bash", str(script)], env=env,
                                        capture_output=True, timeout=30)
                self.assertEqual(result.returncode, 64)
                self.assertFalse(out.exists())

    def test_link_recovery_validates_the_entire_index_before_running(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            host = root / "host"
            (host / "sigobj").mkdir(parents=True)
            (host / "src").mkdir()
            (host / "src/good.sig").write_text("signature good = sig end\n")
            (host / "sigobj/SRCFILES").write_text(
                str(host / "src/good") + "\n" + str(root / "outside") + "\n")
            with patch.object(recover_pinned_links.subprocess, "check_output",
                              side_effect=[recover_pinned_links.HOL_PIN + "\n", ""]), \
                 patch.object(recover_pinned_links.subprocess, "run") as linker:
                with self.assertRaisesRegex(ValueError, "escapes"):
                    recover_pinned_links.restore(host, root / "receipt.json")
                linker.assert_not_called()
            self.assertFalse((root / "receipt.json").exists())

    def test_link_recovery_rejects_an_interrupted_theory_signature(self):
        with tempfile.TemporaryDirectory() as tmp:
            host = Path(tmp)
            objects = host / "src/.hol/objs"
            objects.mkdir(parents=True)
            (objects / "IncompleteTheory.sig").write_bytes(b"")
            with self.assertRaisesRegex(ValueError, "incomplete"):
                recover_pinned_links.indexed_directories(
                    host, (str(host / "src/IncompleteTheory") + "\n").encode())

    def test_link_recovery_rejects_a_signature_link_outside_the_checkout(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            host = root / "host"
            (host / "src").mkdir(parents=True)
            (root / "outside.sig").write_text("signature bad = sig end\n")
            (host / "src/bad.sig").symlink_to(root / "outside.sig")
            with self.assertRaisesRegex(ValueError, "escapes"):
                recover_pinned_links.indexed_directories(
                    host, (str(host / "src/bad") + "\n").encode())

    def test_checked_compile_refuses_existing_evidence_before_checker_runs(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            out = root / "evidence"
            out.mkdir()
            marker = root / "checker-executed"
            host = root / "host"
            (host / "bin").mkdir(parents=True)
            checker = host / "bin/Holmake"
            checker.write_text(f'#!/bin/sh\ntouch "{marker}"\n')
            checker.chmod(0o700)
            env = dict(os.environ, HOLDIR=str(host), CAKEMLDIR=str(root),
                       HOL4_CAKEML_OUT=str(out))
            script = Path(__file__).with_name("cakeml-hol4")
            result = subprocess.run(["bash", str(script), "build",
                                    "tools/cakeml-hol4/fixtures/match.cml"],
                                   env=env, capture_output=True, timeout=30)
            self.assertNotEqual(result.returncode, 0)
            self.assertFalse(marker.exists())
            self.assertEqual(list(out.iterdir()), [])

    def test_failed_prerequisite_stops_the_pipeline(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            host = root / "host"
            cake = root / "cake"
            tools = root / "tools"
            for p in [host / "bin", host / "src/floating-point", cake, tools]:
                p.mkdir(parents=True)
            programs = {
                tools / "git": '#!/bin/sh\n'
                    'if [ "$3" = "rev-parse" ]; then\n'
                    'case "$2" in */host) echo b725f6e8834462a5b4bb2fb67b35e36f368cb8b6;;\n'
                    '*) echo c98da7fc904c5d6d0e9a75a18fac1796a9bfb1f9;; esac\nfi\n',
                host / "bin/Holmake": '#!/bin/sh\nexit 1\n',
                host / "bin/linkToSigobj": '#!/bin/sh\ntouch "$HOLDIR/wrong-link"\n',
            }
            for p, source in programs.items():
                p.write_text(source)
                p.chmod(0o700)
            out = root / "evidence"
            env = dict(os.environ, HOLDIR=str(host), CAKEMLDIR=str(cake),
                       HOL4_PINNED_COMPILER_OUT=str(out),
                       PATH=str(tools) + os.pathsep + os.environ["PATH"])
            script = Path(__file__).with_name("build_pinned_compiler.sh")
            result = subprocess.run(["bash", str(script)], env=env,
                                    capture_output=True, timeout=30)
            self.assertEqual(result.returncode, 1)
            self.assertEqual((out / "STATUS").read_text(),
                             "HOST_PREREQUISITE_BUILD_FAILED\n")
            self.assertEqual((out / "machine_ieeeTheory.uo.exit-code").read_text(), "1\n")
            self.assertFalse((host / "wrong-link").exists())
            self.assertFalse((out / "compiler-build.log").exists())


if __name__ == "__main__":
    unittest.main()
