"""Real HOL4 rejects missing exports before printing any acceptance marker."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

HERE = Path(__file__).resolve().parent
HOLDIR = os.environ.get("HOLDIR")
HOL = Path(HOLDIR) / "bin/hol" if HOLDIR else None


@unittest.skipUnless(HOL and HOL.is_file() and (HOL.parent / "hol.state").is_file(),
                     "a complete built HOLDIR is required")
class Hol4InspectionTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        # A launcher that cannot start must not pass every negative test.
        cp = subprocess.run([str(HOL)], text=True,
            input='val _ = (print "HOL4_INSPECTION_READY\\n"; OS.Process.exit OS.Process.success);',
            stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=30)
        if cp.returncode != 0 or "HOL4_INSPECTION_READY" not in cp.stdout:
            raise AssertionError("HOL4 startup failed: " + cp.stdout)
        help_result = subprocess.run([str(HOL.parent / "Holmake"), "--nolmbc", "--help"],
            text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
            check=True, timeout=30)
        cls.build_flags = ["--qof", "--nolmbc", "--no_preexecs"]
        for flag in ["--no-cache", "--no-project"]:
            if flag in help_result.stdout:
                cls.build_flags.append(flag)

    def reject(self, filename, marker, extra_env=None, fixture=None, fixture_theory="ReplayGateFixture"):
        with tempfile.TemporaryDirectory() as td:
            env = dict(os.environ)
            env.update(extra_env or {})
            env["HOL4_RELEASE_BUNDLE_DIR"] = td
            if fixture:
                (Path(td) / (fixture_theory + "Script.sml")).write_text(fixture)
                built = subprocess.run([str(HOL.parent / "Holmake"), *self.build_flags,
                    fixture_theory + "Theory.uo"], cwd=td, env=env, text=True,
                    stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=30)
                self.assertEqual(built.returncode, 0, built.stdout)
                objects = Path(td) / ".hol/objs"
                if objects.is_dir():
                    env["HOL4_RELEASE_BUNDLE_DIR"] = str(objects)
            if filename == "Hol4MlsexpInspect.sml":
                env["HOL4_MLSEXP_BUILD_DIR"] = td
            cp = subprocess.run(
                [str(HOL)], input=(HERE / "formal" / filename).read_text(),
                cwd=td, env=env, text=True, stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT, timeout=30)
            self.assertNotEqual(cp.returncode, 0, cp.stdout)
            self.assertNotIn(marker, cp.stdout)

    def test_nonexistent_release_theorem_is_rejected(self):
        self.reject("Hol4ProofBundleReplay.sml", "HOL4_PROOF_BUNDLE_OK", {
            "HOL4_RELEASE_BUNDLE_SHA256": "0" * 64,
            "HOL4_RELEASE_THEOREM": "bool.this_theorem_does_not_exist_20261008",
        })

    def test_open_release_theorem_is_rejected(self):
        # All values are bound successfully; the failed check must abort the
        # enclosing operation rather than continue to its success marker.
        self.reject("Hol4ProofBundleReplay.sml", "HOL4_PROOF_BUNDLE_OK", {
            "HOL4_RELEASE_BUNDLE_SHA256": "0" * 64,
            "HOL4_RELEASE_THEOREM": "ReplayGateFixture.open_goal",
        }, 'Theory ReplayGateFixture\nval _ = save_thm ("open_goal", ASSUME boolSyntax.T);\n'
           'val _ = export_theory ();\n')

    def test_missing_macro_exports_are_rejected(self):
        self.reject("Hol4SmlMacroInspect.sml", "HOL4_MACRO_EXPORTS_INSPECTED")

    def test_missing_report_witness_exports_are_rejected(self):
        self.reject("Hol4SmlGapInspect.sml", "HOL4_GAP_WITNESSES_INSPECTED")

    def test_missing_mlsexp_exports_are_rejected(self):
        self.reject("Hol4MlsexpInspect.sml", "HOL4_MLSEXP_EXPORTS_INSPECTED")

    def test_open_mlsexp_exports_are_rejected(self):
        names = ["lex_aux_sexp2tree", "lex_aux_sexp_to_list",
                 "parse_sexp_to_string", "parse_sexp_to_pretty_string",
                 "fromString_sexp_to_string", "fromString_sexp_to_pretty_string"]
        fixture = 'Theory mlsexp\n' + ''.join(
            f'val _ = save_thm ("{name}", ASSUME boolSyntax.T);\n' for name in names)
        fixture += 'val _ = export_theory ();\n'
        self.reject("Hol4MlsexpInspect.sml", "HOL4_MLSEXP_EXPORTS_INSPECTED",
                    fixture=fixture, fixture_theory="mlsexp")


if __name__ == "__main__":
    unittest.main()
