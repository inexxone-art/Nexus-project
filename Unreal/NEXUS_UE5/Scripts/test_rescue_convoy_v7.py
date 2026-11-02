"""Static source contract for the V7 Adlerklamm rescue mission.

These checks are deliberately NOT represented as Unreal editor/build tests.
Actual Chaos physics, vehicle collision and network play need an UE5 runtime.
"""
from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "Source" / "NEXUS"


def code(name):
    return (SRC / name).read_text(encoding="utf-8")


class AdlerklammRescueV7SourceTests(unittest.TestCase):
    def test_convoy_is_server_driven_and_falls_after_crossing(self):
        bus = code("NexusBus.cpp")
        director = code("NexusWorldDirector.cpp")
        self.assertIn("void ANexusBus::AdvanceConvoy(", bus)
        self.assertIn("if(!HasAuthority() || bReleased", bus)
        self.assertIn("LeadPosition.X-3900.f", bus)
        self.assertIn("SetActorLocation(", bus)
        self.assertIn("DOREPLIFETIME(ANexusBus,bReleased)", bus)
        self.assertIn("Bus->AdvanceConvoy(P,GetWorld()->GetDeltaSeconds())", director)
        self.assertIn("if(bEnteredSpan && P.X>4600.f", director)
        self.assertIn("Bus->DropBehindPlayer()", director)
        self.assertIn("CreateRescueHelipad()", director)
        self.assertIn('TEXT("HelipadConcrete")', director)

    def test_rescue_requires_discovery_and_first_aid(self):
        survivor = code("NexusRescueTarget.cpp")
        director = code("NexusWorldDirector.cpp")
        self.assertIn("void ANexusRescueTarget::LocateSurvivor()", survivor)
        self.assertIn("void ANexusRescueTarget::StabilizeSurvivor()", survivor)
        self.assertIn("!bLocated || !bStabilized", survivor)
        self.assertIn("if(!Person->bLocated)", director)
        self.assertIn("if(!Person->bStabilized)", director)
        self.assertIn("return RescuePerson(Person)", director)
        self.assertIn("return TryTriagePerson(Person,true)", director)
        self.assertIn("return TryTriagePerson(Person,false)", director)
        self.assertIn("Difference.Z>400.f && Difference.Z<2400.f", director)

    def test_saves_legacy_and_partial_survivor_progress(self):
        save = code("NexusSaveGame.h")
        director = code("NexusWorldDirector.cpp")
        for field in ("RescuedIds", "LocatedIds", "StabilizedIds"):
            self.assertIn(f"TArray<int32> {field}", save)
            self.assertIn(f"Save->{field}", director)
        self.assertIn("|| bWasRescued", director)
        self.assertLess(director.index("Person->LocateSurvivor();", director.index("void ANexusWorldDirector::LoadProgress")),
                        director.index("Person->MarkRescued();", director.index("void ANexusWorldDirector::LoadProgress")))

    def test_coop_role_and_rescue_references_replicate(self):
        director = code("NexusWorldDirector.cpp")
        explorer = code("NexusExplorer.cpp")
        vehicle = code("NexusVehicle.cpp")
        gm = code("NexusGameMode.cpp")
        hud = code("NexusHUD.cpp")
        self.assertIn("DOREPLIFETIME(ANexusExplorer,SelectedRescueRole)", explorer)
        self.assertIn("DOREPLIFETIME(ANexusVehicle,DriverRescueRole)", vehicle)
        self.assertIn("SeatedFootPawns.FindRef(Requester)", gm)
        self.assertIn("Requester->GetPawn()", gm)
        self.assertIn("Vehicle->DriverRescueRole=Passenger->SelectedRescueRole", gm)
        self.assertIn("Vehicle->DriverRescueRole!=ENexusRescueRole::Pilot", director)
        for actor_ref in ("Bridge", "Bus", "RescueHelicopter", "Survivors"):
            self.assertIn(f"DOREPLIFETIME(ANexusWorldDirector,{actor_ref})", director)
        self.assertIn("LocalExplorer->SelectedRescueRole", hud)
        self.assertIn("D->LocatedCount()", hud)
        self.assertIn("D->StabilizedCount()", hud)
        self.assertIn("FVector::DistSquared", hud)

    def test_opening_mission_is_correctly_located(self):
        import json

        campaign = json.loads((ROOT / "Content" / "Data" / "nexus_campaign.json").read_text())
        first = campaign["missions"][0]
        self.assertEqual(first["id"], "NEXUS_01")
        self.assertEqual(first["region"], "adlerklamm")


if __name__ == "__main__":
    unittest.main()
