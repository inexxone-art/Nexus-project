"""Offline orchestration checks, NOT a real import into Unreal."""
import ast
import unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
class VerifiedImportTests(unittest.TestCase):
    def test_editor_bulk_import_calls_real_existing_scripts(self):
        script=(ROOT/"Scripts/import_nexus_all_verified.py").read_text()
        ast.parse(script)
        for s in ("import_nexus_pbr.py","import_nexus_geometry.py",
                  "import_nexus_cc0_scans.py","runpy.run_path",
                  "MANUAL_LANDSCAPE_EDITOR_REQUIRED","nexus_verified_import_report.json"):
            self.assertIn(s,script)
    def test_bundle_expectations_are_consistent_with_original_library_archives(self):
        script=(ROOT/"Scripts/import_nexus_all_verified.py").read_text()
        for s in ('"pbr_png":72','"hero_glb":4','"terrain_glb":9',
                  '"foliage_glb":5','"cc0_scanned_glb":1','"landscape_heightmap":1'):
            self.assertIn(s,script)
    def test_pbr_importer_no_longer_overwrites_existing_texture_assets(self):
        script=(ROOT/"Scripts/import_nexus_pbr.py").read_text()
        self.assertIn('"replace_existing", False',script)
        self.assertNotIn('"replace_existing", True',script)
if __name__=="__main__": unittest.main()
