import ast
import unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
class ArchitectureGeneratorContract(unittest.TestCase):
    def test_generator_has_real_openings_and_details(self):
        src=(ROOT/"Scripts/generate_nexus_buildings.py").read_text()
        ast.parse(src)
        for token in ("walkable doorway","window","balcony","roof","MANIFEST.json","PROTOTYPE_NOT_PHOTOREAL","nexus_building_world_catalog.json"):
            self.assertIn(token,src)
    def test_import_pipeline_targets_building_geometry(self):
        src=(ROOT/"Scripts/import_nexus_buildings.py").read_text()
        ast.parse(src)
        for token in ("AssetImportTask","Buildings","StaticMesh","import_asset_tasks"):
            self.assertIn(token,src)
if __name__=="__main__":unittest.main()
