"""Contract tests for the comprehensive AAA map/building/planet design brief.
These check machine-readable plans and existing campaign data, not rendered art.
"""
import json
import unittest
from pathlib import Path

PROJECT=Path(__file__).resolve().parents[1]
DATA=PROJECT/"Content"/"Data"

def read_json(name):
    return json.loads((DATA/name).read_text(encoding="utf-8"))

class MasterPlanChecks(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.catalog=read_json("nexus_building_world_catalog.json")
        cls.planets=read_json("nexus_world_profiles.json")
        cls.campaign=read_json("nexus_campaign.json")
        cls.doc=(PROJECT/"Docs"/"NEXUS_AAA_MASTER_BAUPLAN.md").read_text(encoding="utf-8")

    def test_complete_building_library(self):
        c=self.catalog
        self.assertEqual(len(c["buildings"]),24)
        self.assertEqual(len({x["id"] for x in c["buildings"]}),24)
        self.assertTrue(all(x["surface_palettes"] and x["interior_modules"] for x in c["buildings"]))
        self.assertTrue(all(x["asset_status"]=="DESIGN_ONLY" for x in c["buildings"]))
        required={"foundation","wall","window_frame","roof","interior","damage","repair"}
        self.assertTrue(required.issubset(set(c["architecture_standard"]["modules"])))

    def test_worlds_match_existing_ue_profile_ids(self):
        actual={x["id"] for x in self.planets["areas"]}
        planned={x["id"] for x in self.catalog["worlds"]}
        self.assertEqual(actual,planned)
        self.assertEqual(len(actual),14)
        for world in self.catalog["worlds"]:
            self.assertTrue(world["building_catalog_ids"])
            self.assertIn(world["access"],("surface_local","orbit_only","extreme_conditions_station"))

    def test_each_world_building_is_in_catalog(self):
        ids={x["id"] for x in self.catalog["buildings"]}
        for world in self.catalog["worlds"]:
            with self.subTest(world=world["id"]):
                self.assertTrue(set(world["building_catalog_ids"]).issubset(ids))
        for gas in ["jupiter","saturn","uranus","neptune"]:
            self.assertEqual(next(w for w in self.catalog["worlds"] if w["id"]==gas)["access"],"orbit_only")

    def test_48hour_campaign_is_explicitly_a_target(self):
        c=self.catalog["campaign"]
        self.assertEqual(c["missions"],18)
        self.assertEqual(c["phases_per_mission"],7)
        self.assertEqual(c["target_hours"],48)
        self.assertEqual(len(self.campaign["missions"]),18)
        self.assertTrue(all(len(m["phases"])==7 for m in self.campaign["missions"]))
        self.assertIn("Ziel",self.doc)
        self.assertIn("kein derzeit gemessener Wert",self.doc)

    def test_alpine_river_crosses_bridge(self):
        alpine=next(x for x in self.catalog["maps"] if x["id"]=="L_Adlerklamm_VerticalSlice")
        self.assertEqual(alpine["size_km"],[2,2])
        self.assertIn("82mBridge",alpine["zones"])
        self.assertIn("MeanderingRiver",alpine["zones"])
        self.assertIn("Prallhang",self.doc)
        self.assertIn("Gleithang",self.doc)
        self.assertIn("Nord",self.doc)
        self.assertIn("Süd",self.doc)

    def test_zero_budget_and_honest_gates(self):
        self.assertEqual(self.catalog["spending_eur"],0)
        self.assertEqual(self.catalog["engine"],"Unreal Engine 5.8")
        for gate in ["G1_UE5_REAL_BUILD","G3_HERO_BUILDINGS","G8_PHOTOREALISM_GPU_REVIEW"]:
            self.assertIn(gate,self.catalog["gates"])
        self.assertGreaterEqual(len(self.catalog["must_not_claim"]),4)
        self.assertIn("nicht",self.doc.lower())
        self.assertIn("Intel UHD 620",self.doc)

if __name__=="__main__":unittest.main()
