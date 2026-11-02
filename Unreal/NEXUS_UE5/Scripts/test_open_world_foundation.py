"""Source-level checks for the first actual NEXUS open-world extension.

Offline only; Unreal Editor compilation and rendered playtest still required.
"""
import ast
from pathlib import Path
import unittest

ROOT=Path(__file__).resolve().parents[1]
SOURCE=ROOT/"Source"/"NEXUS"
def read(n):return (SOURCE/n).read_text(encoding="utf-8")

class OpenWorldFoundationTests(unittest.TestCase):
    def test_home_and_pinboard_have_real_geometry_and_discoveries(self):
        house=read("NexusStarterHome.cpp")
        world=read("NexusWorldDirector.cpp")
        ui=read("NexusHUD.cpp")
        self.assertIn("WalkableFloor",house)
        self.assertIn("FrontLeft",house)
        self.assertIn("FrontRight",house)
        self.assertIn("Pinboard",house)
        self.assertIn("ANexusStarterHome::IsNearPinboard",house)
        self.assertIn("SpawnActor<ANexusStarterHome>",world)
        self.assertIn("TeleportToStarterHome",read("NexusGameMode.cpp"))
        self.assertIn("GetDiscoveredBoardLines",ui)
        self.assertNotIn("UnlockTopic(TEXT(\"sector31\"))",world)
    def test_gold_and_sawmill_have_input_and_output_and_costs(self):
        typ=read("NexusTypes.h")
        world=read("NexusWorldDirector.cpp")
        for term in ("GoldMine","Sawmill"):
            self.assertIn(term,typ)
            self.assertIn("ENexusIndustry::"+term,world)
        for term in ('Output.Add(TEXT("GoldOre"),2)','Output.Add(TEXT("Planks"),5)',
                     'Need.Add(TEXT("Wood"),3);Output.Add(TEXT("Planks"),5)',
                     'Credits+=180'):
            self.assertIn(term,world)
    def test_property_and_mine_persist_server_and_replicate(self):
        world=read("NexusWorldDirector.cpp")
        save=read("NexusSaveGame.h")
        for term in ("DiscoveredTopics","RentalProperties"):
            self.assertIn(term,save)
            self.assertIn("Save->"+term+"=",world)
            self.assertIn("DOREPLIFETIME(ANexusWorldDirector,"+term+")",world)
        for term in ("SettleRentAtMidnight","LastPaidDay","WorldMemory->GameDay++","PurchaseRentalProperty",
                     "PublishInventory()","Stock.Get(TEXT(\"GoldOre\"))<1"):
            self.assertIn(term,world)
        self.assertIn("GetActorLocation()",read("NexusExplorer.cpp"))
        ini=(ROOT/"Config/DefaultInput.ini").read_text()
        for key in ("TogglePinboard","TogglePhone","SellGold","BuyRental"):
            self.assertIn("ActionName=\""+key+"\"",ini)
if __name__=="__main__":unittest.main()
