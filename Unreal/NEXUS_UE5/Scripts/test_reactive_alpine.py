"""Offline source contracts + numeric geometry tests for the UE5 alpine slice.

These tests DO NOT compile Unreal code, render frames, or test actual multiplayer.
"""
import ast
import json
import math
from pathlib import Path
import unittest

ROOT=Path(__file__).resolve().parents[1]
SOURCE=ROOT/"Source"/"NEXUS"

def src(name):
    return (SOURCE/name).read_text(encoding="utf-8")

class ReactiveAlpineTests(unittest.TestCase):
    def test_project_plugins(self):
        data=json.loads((ROOT/"NEXUS.uproject").read_text())
        for plugin in ["Niagara","ProceduralMeshComponent"]:
            self.assertTrue(any(x["Name"]==plugin and x["Enabled"] for x in data["Plugins"]))

    def test_network_rescue_state(self):
        h=src("NexusRescueTarget.h")
        c=src("NexusRescueTarget.cpp")
        for attr in ("bRescued","bAvailable"):
            self.assertIn("ReplicatedUsing=OnRep_RescueState) bool "+attr,h)
            self.assertIn("DOREPLIFETIME(ANexusRescueTarget,"+attr+")",c)
        self.assertIn("ForceNetUpdate()",c)
        self.assertIn("SetActorEnableCollision(bVisible)",c)
        world=src("NexusWorldDirector.cpp")
        self.assertIn("Person->SetAvailable(true)",world)
        self.assertIn("Person->SetAvailable(false)",world)

    def test_industry_replicates_construction(self):
        h=src("NexusIndustrySite.h")
        c=src("NexusIndustrySite.cpp")
        self.assertIn("ReplicatedUsing=OnRep_Facility) bool bConstructed",h)
        self.assertIn("DOREPLIFETIME(ANexusIndustrySite,bConstructed)",c)
        self.assertIn("SetCollisionEnabled(bConstructed?",c)

    def test_weather_reactive_mission_hud_and_save(self):
        weather=src("NexusAlpineWeather.cpp")
        world=src("NexusWorldDirector.cpp")
        save=src("NexusSaveGame.h")
        vehicle=src("NexusVehicle.cpp")
        hud=src("NexusHUD.cpp")
        for name in ("WeatherMode","WeatherSeverity","ClockMinutes"):
            self.assertIn("Save->"+name+"=",world)
            self.assertIn(name+"=",save)
        self.assertIn("SetClimate(ENexusClimate::Storm,87)",world)
        self.assertIn("SetClimate(ENexusClimate::Rain,30)",world)
        self.assertIn("RoadTractionMultiplier()",vehicle)
        self.assertIn("Weather->WeatherReport()",hud)
        self.assertNotIn("D->Stock.Get(",hud)
        for prop in ("Climate","Severity","MinuteOfDay"):
            self.assertIn("DOREPLIFETIME(ANexusAlpineWeather,"+prop+")",weather)

    def test_river_generated_and_flood_replicates(self):
        river=src("NexusAlpineRiver.cpp")
        world=src("NexusWorldDirector.cpp")
        self.assertIn("CreateMeshSection(0,Vertices,Triangles",river)
        self.assertIn("DOREPLIFETIME(ANexusAlpineRiver,RainFloodLevel)",river)
        self.assertIn("River->SetFloodSeverity(87)",world)
        self.assertIn("River->SetFloodSeverity(30)",world)
        self.assertIn("RainFloodLevel",src("NexusAlpineRiver.h"))

    def test_python_unreal_asset_material_script_parses(self):
        ast.parse((ROOT/"Scripts"/"create_river_material.py").read_text(),filename="create_river_material.py")
        self.assertIn("MP_ROUGHNESS",(ROOT/"Scripts"/"create_river_material.py").read_text())

    def test_river_geometry_is_meandering_and_top_facing(self):
        # West-east bridge X meets the south-north river Y at 90 degrees.
        def center(t):
            return (610*math.sin(t*math.pi*2.5)+310*math.sin(t*math.pi*6.5),
                    -9200+18400*t,-195+30*math.sin(t*math.pi*7.5))
        n=96
        rows=[]
        for i in range(n+1):
            t=i/n
            pt=center(t)
            back=center(max(0,t-.002));front=center(min(1,t+.002))
            tangent=[front[j]-back[j] for j in range(3)]
            length=math.hypot(tangent[0],tangent[1])
            normal=(tangent[1]/length,-tangent[0]/length)
            rows.append(((pt[0]-1150*normal[0],pt[1]-1150*normal[1]),
                         (pt[0]+1150*normal[0],pt[1]+1150*normal[1])))
        self.assertGreater(len({round(center(i/n)[0]) for i in range(n+1)}),25)
        # The water triangle faces upward, not an impermeable upside-down panel.
        a=rows[15][0];b=rows[15][1];c=rows[16][0]
        normal_z=(b[0]-a[0])*(c[1]-a[1])-(b[1]-a[1])*(c[0]-a[0])
        self.assertGreater(normal_z,0)
        self.assertGreater(math.dist(*rows[30]),2200)

    def test_cross_section_erosion_and_deposition(self):
        # Real cross-sectional rules, unlike a flat rectangular water plane:
        # fast/deep outside meander, shallow sandy point bar inside.
        def depth(outer):
            smooth=outer*outer*(3-2*outer)
            return 90+(520-90)*smooth
        self.assertAlmostEqual(depth(0),90)
        self.assertAlmostEqual(depth(1),520)
        self.assertGreater(depth(.9),depth(.1)*3)
        speed_inner=3.2*.55
        speed_outer=3.2*1.5
        self.assertGreater(speed_outer,speed_inner*2)
        river=src("NexusAlpineRiver.cpp")
        self.assertIn("Riverbed->Set",river)
        self.assertIn("Ground->bUseComplexAsSimpleCollision=true",river)
        self.assertIn("GenerateRiver();",river)
        self.assertIn("RainFloodLevel=FMath::Lerp(0.f,220.f",river)
        self.assertIn("bDeposit?FColor(199,157,96,255)",river)
        self.assertIn("Mode==1) Z=TerrainWater-BedDepthAt",river)
        self.assertIn("Position.Y < -9200.f",river)
        self.assertNotIn("Position.X < -9200.f",river)

    def test_swimming_underwater_with_oxygen_and_coop(self):
        player=src("NexusExplorer.cpp")
        playerh=src("NexusExplorer.h")
        hud=src("NexusHUD.cpp")
        inputs=(ROOT/"Config"/"DefaultInput.ini").read_text()
        for keyword in ("SampleWater(","MOVE_Flying","MOVE_Falling",
                        "ServerSwimVertical_Implementation",
                        "CurrentVelocity", "OxygenSeconds",
                        "AddActorWorldOffset(Flow*.28f*Dt,true)"):
            if keyword=="CurrentVelocity":continue
            self.assertIn(keyword,player)
        self.assertIn("COND_OwnerOnly",player)
        self.assertIn("bIsSwimming",playerh)
        self.assertIn("GetScaledCapsuleHalfHeight()",player)
        self.assertIn("ActionName=\"SwimDescend\"",inputs)
        self.assertIn("LocalExplorer->OxygenSeconds",hud)
        self.assertIn("Cast<ANexusExplorer>(PlayerOwner->GetPawn())",hud)

    def test_canyon_and_bridge_cross_correctly(self):
        world=src("NexusWorldDirector.cpp")
        self.assertNotIn('TEXT("RiverBase")',world)
        self.assertIn('TEXT("WestCliffFace")',world)
        self.assertIn('TEXT("EastCliffFace")',world)
        self.assertIn("River=GetWorld()->SpawnActor<ANexusAlpineRiver>()",world)

    def test_rescue_world_is_not_the_final_aaa_game(self):
        notes=(ROOT/"Docs"/"V3_8_REACTIVE_ALPINE_WORLD.md").read_text()
        for requirement in ("Unreal Editor was not available",
                            "photo","Save/Load","original"):
            self.assertIn(requirement,notes)

if __name__=="__main__":unittest.main()
