import io
from pathlib import Path
import tarfile
import tempfile
import unittest

from restore_tactictoe_cache import unpack


def archive(name, kind=tarfile.REGTYPE):
    buffer = io.BytesIO()
    with tarfile.open(fileobj=buffer, mode="w:gz") as tar:
        item = tarfile.TarInfo(name)
        item.type = kind
        item.linkname = "../../outside"
        tar.addfile(item, io.BytesIO())
    return buffer.getvalue()


class CacheConfinementTests(unittest.TestCase):
    def test_parent_escape_is_rejected(self):
        with tempfile.TemporaryDirectory() as tmp:
            target = Path(tmp) / "cache"
            with self.assertRaises(ValueError):
                unpack(archive("tactictoe-cache/../../outside"), target)
            self.assertFalse(target.exists())

    def test_links_are_rejected(self):
        with tempfile.TemporaryDirectory() as tmp:
            for kind in [tarfile.SYMTYPE, tarfile.LNKTYPE]:
                with self.assertRaises(ValueError):
                    unpack(archive("tactictoe-cache/link", kind), Path(tmp) / "cache")

    def test_existing_progress_is_preserved(self):
        with tempfile.TemporaryDirectory() as tmp:
            target = Path(tmp) / "cache"
            target.mkdir()
            marker = target / "progress"
            marker.write_text("keep")
            with self.assertRaises(ValueError):
                unpack(archive("tactictoe-cache/file"), target)
            self.assertEqual(marker.read_text(), "keep")
