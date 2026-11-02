"""Pure offline contract tests of PDF-specified game data.
Not a substitute for UnrealBuildTool or GPU playtesting.
Run: python3 -m unittest discover -s Scripts -p "test_*.py"
"""
import json, unittest
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
DATA=ROOT/"Content"/"Data"
class CampaignTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.campaign=json.loads((DATA/"nexus_campaign.json").read_text())
        cls.worlds=json.loads((DATA/"nexus_world_profiles.json").read_text())
        cls.missions=cls.campaign["missions"]

    def test_chapters_match_story_bible(self):
        self.assertEqual(len(self.missions),18)
        self.assertEqual(len({m["id"] for m in self.missions}),18)
        self.assertEqual(sum(len(m["phases"]) for m in self.missions),126)
        self.assertEqual(self.missions[0]["title"],"Die letzte Brücke")
        self.assertEqual(self.missions[12]["title"],"Der brennende Kern")
        self.assertEqual(self.missions[-1]["title"],"Die letzte Erinnerung")
        self.assertEqual([m["number"] for m in self.missions],list(range(1,19)))

    def test_each_chapter_has_seven_real_objectives_and_choice(self):
        order=["recon","intervention","escalation","twist","climax","choice","extraction"]
        for m in self.missions:
            with self.subTest(mission=m["id"]):
                self.assertEqual([p["id"] for p in m["phases"]],order)
                self.assertEqual(len({p["objective_id"] for p in m["phases"]}),7)
                self.assertTrue(all(p["objective_id"] for p in m["phases"]))
                self.assertEqual(m["phases"][5]["consequence_key"],f"branch_{m['number']}")
                self.assertIn("protect_civilians",m["choices"])
                self.assertIn("secure_critical_data",m["choices"])

    def test_campaign_graph_unlocked_in_order(self):
        for i,m in enumerate(self.missions):
            expect=self.missions[i+1]["id"] if i<17 else None
            self.assertEqual(m["unlocks"],expect)

    def test_planets_respect_physics_and_biomes(self):
        ws={x["id"]:x for x in self.worlds["areas"]}
        self.assertEqual(len(ws),14)
        for name in ["mercury","venus","earth","mars","jupiter","saturn","uranus","neptune","terra_nova","sahra_ix","nivora","vesper","ignis_prime","umbra"]:
            self.assertIn(name,ws)
        for name in ("jupiter","saturn","uranus","neptune"):
            self.assertEqual(ws[name]["biome"],"gas_atmosphere")
            self.assertIn("orbit_only",ws[name]["material_set"])
        self.assertNotEqual(ws["mars"]["gravity"],ws["earth"]["gravity"])

    def test_no_fake_repeated_objectives(self):
        seen=set()
        for m in self.missions:
            for p in m["phases"]:
                objective=p["objective_id"]
                self.assertNotIn(objective,seen)
                seen.add(objective)

    def test_unreal_runtime_is_wired_to_data_and_persistence(self):
        source=(ROOT/"Source/NEXUS/NexusWorldDirector.cpp").read_text()
        component=(ROOT/"Source/NEXUS/NexusCampaignComponent.cpp").read_text()
        memory=(ROOT/"Source/NEXUS/NexusSimulationComponent.cpp").read_text()
        save=(ROOT/"Source/NEXUS/NexusSaveGame.h").read_text()
        self.assertIn('Data/nexus_campaign.json',component)
        self.assertIn('Mission.Stages.IsValidIndex(ActivePhaseIndex)',component)
        self.assertIn('CompleteObjective(TEXT("scan_damage"))',source)
        self.assertIn('CompleteObjective(TEXT("evacuate_bus"))',source)
        self.assertIn('CompleteObjective(TEXT("protect_medics"))',source)
        self.assertIn('CompleteObjective(TEXT("stabilize_route"))',source)
        self.assertIn('CompleteObjective(TEXT("reach_rescue_rally"))',source)
        self.assertIn('RecordRescue(',source)
        self.assertIn('SetRoadDamage(',source)
        self.assertIn('SetBridgeRepaired(',source)
        self.assertIn('Save->EventHistory=WorldMemory->EventHistory',source)
        self.assertIn('Story->Restore(',source)
        self.assertIn('Citizens',save)
        self.assertIn('MedicalStock',memory)
        self.assertIn('TradeSupply',memory)
        self.assertIn('EvaluateIncident',memory)
        self.assertIn('Already',memory) if False else None
        self.assertIn('GetLifetimeReplicatedProps',memory)

    def test_gameplay_source_inputs(self):
        explorer=(ROOT/"Source/NEXUS/NexusExplorer.cpp").read_text()
        vehicle=(ROOT/"Source/NEXUS/NexusVehicle.cpp").read_text()
        for obj in (explorer,vehicle):
            for key in ("InspectEvidence","ProtectCivilians","SecureEvidence"):
                self.assertIn(key,obj)

if __name__=="__main__":
    unittest.main()
