"""Offline C++ source contracts for Earth civilian fleet and separated historical tanks."""
import unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
SRC=ROOT/"Source"/"NEXUS"
def read(x):return (SRC/x).read_text()
class FleetAndDistrictTests(unittest.TestCase):
    def test_fleet_mesh_driving_and_replication(self):
        vehicle=read("NexusVehicle.cpp")
        head=read("NexusVehicle.h")
        world=read("NexusWorldDirector.cpp")
        game=read("NexusGameMode.cpp")
        for name in ("Sportscar","PoliceCar","Ambulance","FireTruck","UtilityHelicopter",
                     "HeavyUtilityHelicopter","HistoricArmoredTank"):
            self.assertIn(name,head)
        self.assertIn("DOREPLIFETIME(ANexusVehicle,VehicleType)",vehicle)
        self.assertIn("ConfigureVehicle",vehicle)
        self.assertIn("CreateFleet()",world)
        self.assertIn("TActorIterator<ANexusVehicle>",game)
        fleet=world[world.index("void ANexusWorldDirector::CreateFleet()"):world.index("void ANexusWorldDirector::Inform(")]
        self.assertNotIn("ENexusVehicleType::HistoricArmoredTank",fleet)
        self.assertIn("ENexusVehicleType::Sportscar",fleet)
    def test_real_city_mesh_slots_or_walkable_fallback(self):
        src=read("NexusCityDistrict.cpp")
        for n in ("Supermarket","PoliceStation","FireStation","AirportTerminal",
                  "MedievalHall","AlpineVilla","GoldMineEntrance","SpaceResearchLab"):
            self.assertIn(n,src)
        self.assertIn("LoadObject<UStaticMesh>",src)
        self.assertIn("CreateFallbackBuilding",src)
        self.assertIn("DoorTop",src)
        self.assertIn("SetCollisionProfileName",src)
if __name__=="__main__":unittest.main()
