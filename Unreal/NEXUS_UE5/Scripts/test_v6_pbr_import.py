"""Offline source check for the V6 PBR/motion importers (no Unreal Editor)."""
import ast
from pathlib import Path
import unittest
ROOT=Path(__file__).resolve().parents[1]
class V6Sources(unittest.TestCase):
    def test_editor_scripts_parse_and_do_not_overwrite(self):
        for name in ("import_nexus_v6_pbr.py","import_nexus_v6_motion.py","download_nexus_cc0_materials.py"):
            source=(ROOT/"Scripts"/name).read_text(encoding="utf-8")
            ast.parse(source)
        mats=(ROOT/"Scripts/import_nexus_v6_pbr.py").read_text()
        self.assertIn("MP_METALLIC",mats)
        self.assertIn("MP_ROUGHNESS",mats)
        self.assertIn("MP_NORMAL",mats)
        self.assertIn('"srgb"',mats)
        self.assertIn('"replace_existing",False',mats)
        self.assertIn("PBR_V6",mats)
        motion=(ROOT/"Scripts/import_nexus_v6_motion.py").read_text()
        for s in ("NexusV6Motion","sha256","/Game/AAA/Geometry/Animated",
                  "/Game/AAA/Geometry/MotionBodies"):
            self.assertIn(s,motion)
    def test_reliable_provenance(self):
        downloader=(ROOT/"Scripts/download_nexus_cc0_materials.py").read_text()
        self.assertIn("polyhaven.com",downloader)
        self.assertIn("CC0-1.0",downloader)
        self.assertIn("Powered by Poly Haven",downloader)
        self.assertIn("CC0_PROVENANCE.json",downloader)
if __name__=="__main__":unittest.main()
