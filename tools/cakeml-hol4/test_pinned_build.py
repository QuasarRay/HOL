"""A failed host proof build must stop before linking or claiming success."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


class PinnedBuildBoundaryTests(unittest.TestCase):
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
            self.assertFalse((host / "wrong-link").exists())
            self.assertFalse((out / "compiler-build.log").exists())


if __name__ == "__main__":
    unittest.main()
