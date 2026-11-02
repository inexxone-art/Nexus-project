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
        def center(t):
            return (-9200+18400*t,610*math.sin(t*math.pi*2.5)+310*math.sin(t*math.pi*6.5),-195+30*math.sin(t*math.pi*7.5))
        n=80
        rows=[]
        for i in range(n+1):
            t=i/n
            pt=center(t)
            back=center(max(0,t-.002)); front=center(min(1,t+.002))
            tangent=[front[j]-back[j] for j in range(3)]
            length=math.hypot(tangent[0],tangent[1])
            normal=(tangent[1]/length,-tangent[0]/length)
            rows.append(((pt[0]-1150*normal[0],pt[1]-1150*normal[1]),
                         (pt[0]+1150*normal[0],pt[1]+1150*normal[1])))
        self.assertGreater(len({round(center(i/n)[1]) for i in range(n+1)}),25)
        # The first physical triangle must have an upward-facing normal.
        a=rows[15][0];b=rows[15][1];c=rows[16][0]
        cross_z=(b[0]-a[0])*(c[1]-a[1])-(b[1]-a[1])*(c[0]-a[0])
        self.assertGreater(cross_z,0,"Unreal water mesh is wound upside-down")
        self.assertGreater(math.dist(*rows[30]),2000)

    def test_rescue_world_is_not_the_final_aaa_game(self):
        notes=(ROOT/"Docs"/"V3_8_REACTIVE_ALPINE_WORLD.md").read_text()
        for requirement in ("Unreal Editor was not available",
                            "photo","Save/Load","original"):
            self.assertIn(requirement,notes)

if __name__=="__main__":unittest.main()
