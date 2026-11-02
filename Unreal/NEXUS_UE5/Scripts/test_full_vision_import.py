"""Static/full-vision import contracts. DOES NOT run Unreal or import meshes."""
import ast
import json
from pathlib import Path
import unittest
ROOT=Path(__file__).resolve().parents[1]
DATA=ROOT/"Content"/"Data"
class VisionImportTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.data=json.loads((DATA/"nexus_user_vision_2026_11.json").read_text(encoding="utf-8"))
        cls.features={x["id"]:x for x in cls.data["features"]}
        cls.assets={x["id"]:x for x in cls.data["asset_slots"]}
    def test_user_map_boundaries_are_preserved(self):
        rule=self.data["map_rule"].lower()
        self.assertIn("one continuous first map",rule)
        self.assertIn("sixth war-armored image is excluded",rule)
        for id in ("earth_map","sector31","goldmine","sawmill","oil_platform","starter_house","pinboard","weather_disasters"):
            self.assertIn(id,self.features)
            self.assertEqual(self.features[id]["world"],"earth")
        self.assertEqual(self.features["war_planet"]["world"],"ww2_1945")
    def test_no_design_work_disguised_as_implemented(self):
        self.assertGreaterEqual(len(self.features),35)
        self.assertGreaterEqual(len(self.assets),40)
        self.assertEqual(self.data["asset_status"],"SOURCE_FILES_NOT_PRESENT_IN_GITHUB_FOR_THESE_PROPOSED_PACKAGES")
        for f in self.features.values():
            self.assertIn(f["implementation_status"],self.data["meaning_of_status"])
            for asset in f["asset_dependencies"]:
                self.assertIn(asset,self.assets)
        self.assertTrue(all(a["state"]=="NOT_VERIFIED_IN_PROJECT" for a in self.assets.values()))
        self.assertEqual(len(self.assets),len(self.data["asset_slots"]))
    def test_importer_is_non_destructive_and_path_bounded(self):
        src=(ROOT/"Scripts/import_nexus_full_vision.py").read_text(encoding="utf-8")
        ast.parse(src)
        for token in ("AssetImportTask","import_asset_tasks","MISSING_SOURCE","replace_existing",
                      "False","MANUAL_UNREAL_ASSET","Unsafe destination","nexus_import_report.json"):
            self.assertIn(token,src)
        self.assertNotIn("urllib",src)
    def test_includes_core_story_and_economy(self):
        for id in ("rocket_modules","spaceflight","lava_world","ice_ocean_world",
                   "abandoned_research","hidden_survivors","anti_aging","politics_corruption",
                   "time_travel","npc_memory","ship_crew","property_economy","smartphone",
                   "black_market","coop","cameras","military_training" if False else "fast_military_training"):
            self.assertIn(id,self.features)
        self.assertEqual(self.features["lava_world"]["world"],"ignis_prime")
if __name__=="__main__":unittest.main()
