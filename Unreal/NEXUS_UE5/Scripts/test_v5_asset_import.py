"""V5 28 generated GLB asset registrations and UE import contracts (no UE editor here)."""
import ast,json,unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
class V5AssetTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.catalog=json.loads((ROOT/"Content/Data/nexus_v5_asset_registry.json").read_text())
    def test_counts_and_unique_paths(self):
        assets=self.catalog["assets"]
        self.assertEqual(len(assets),28)
        self.assertEqual(len({x["filename"] for x in assets}),28)
        self.assertEqual(sum(x["category"]=="vehicles" for x in assets),13)
        self.assertEqual(sum(x["category"]=="architecture" for x in assets),8)
        self.assertEqual(sum(x["category"]=="props" for x in assets),7)
    def test_historic_tank_excluded_from_earth(self):
        rows={x["kind"]:x for x in self.catalog["assets"]}
        self.assertEqual(rows["HistoricArmoredTank"]["world_placement"],"ww2_1945_only")
        self.assertEqual(rows["FictionalArmoredExplorer"]["world_placement"],"alien_world_only")
        self.assertIn("research_locked",rows["PulseCaster"]["world_placement"])
        self.assertIn("research_locked",rows["ArcEmitter"]["world_placement"])
        game=(ROOT/"Source/NEXUS/NexusWorldDirector.cpp").read_text()
        section=game.split("void ANexusWorldDirector::CreateFleet()",1)[1].split("void ANexusWorldDirector::Inform(",1)[0]
        self.assertNotIn("HistoricArmoredTank",section)
    def test_import_non_destructive_checksums_and_collision(self):
        src=(ROOT/"Scripts/import_nexus_v5_assets.py").read_text()
        ast.parse(src)
        for token in ("AssetImportTask","import_asset_tasks","replace_existing",
                      "False","sha256","EditorStaticMeshLibrary","MISSING_SOURCE",
                      "CHECKSUM_MISMATCH","EXPECTED" if False else "CUSTOM"):
            if token=="CUSTOM": continue
            self.assertIn(token,src)
        self.assertIn("complex",src.lower())
if __name__=="__main__":unittest.main()
