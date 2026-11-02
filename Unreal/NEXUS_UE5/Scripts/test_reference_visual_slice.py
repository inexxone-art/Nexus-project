"""Source-level verification of reference-style presentation and camera controls.

Pure static tests: do not claim an Unreal Editor build or screenshot match.
"""
import ast
from pathlib import Path
import unittest

ROOT=Path(__file__).resolve().parents[1]
SRC=ROOT/"Source"/"NEXUS"

def read(filename):
    return (SRC/filename).read_text(encoding="utf-8")

class ReferenceVisualSliceTests(unittest.TestCase):
    def test_reference_hud_is_state_driven(self):
        hud=read("NexusHUD.cpp")
        for value in ("ADLERKLAMM","ROHSTOFFE","WIEDERAUFBAU - BRUECKE",
                      "D->RescuedCount()","D->RebuildStage","D->GetResourceCount",
                      "D->Credits","Weather->WeatherReport()",
                      "FUNK / NOTRUF","D->RadioMessage","D->Bridge->GetActorLocation()"):
            self.assertIn(value,hud)
        self.assertNotIn("30 | 270",hud)
        self.assertNotIn("DrawRect(FLinearColor::Red",hud)

    def test_toggle_is_available_foot_and_vehicle(self):
        key=(ROOT/"Config"/"DefaultInput.ini").read_text()
        self.assertIn('ActionName="ToggleCamera",Key=V',key)
        for filename in ("NexusExplorer.cpp","NexusVehicle.cpp"):
            src=read(filename)
            self.assertIn('BindAction(TEXT("ToggleCamera")',src)
            self.assertIn("void A",src)
            self.assertIn("::ToggleCamera()",src)
            self.assertIn("SetActive(",src)
        self.assertIn("bDoCollisionTest=true",read("NexusExplorer.cpp"))

    def test_genuine_rendering_pipeline_hooks(self):
        world=read("NexusWorldDirector.cpp")
        look=read("NexusCinematicLook.cpp")
        self.assertIn("SpawnActor<ANexusCinematicLook>()",world)
        for word in ("USkyAtmosphereComponent","UPostProcessComponent",
                     "bUnbound=true","ColorSaturation","ColorContrast",
                     "VignetteIntensity","ANexusAlpineWeather"):
            self.assertIn(word,look)
        self.assertIn("BeaconBlue->SetIntensity",read("NexusVehicle.cpp"))
        self.assertIn("BeaconRed->SetIntensity",read("NexusVehicle.cpp"))
        self.assertIn("HelicopterSearchLight->SetVisibility(bHelicopter)",read("NexusVehicle.cpp"))
        self.assertIn("MulticastCollapseDust(Piece->GetComponentLocation())",read("NexusBridge.cpp"))
        self.assertIn("LineTraceSingleByChannel(Hit",read("NexusCinematicScenery.cpp"))

    def test_no_misleading_pretence_of_editor_render(self):
        doc=(ROOT/"Docs"/"REFERENCE_VISUAL_SLICE_V4.md").read_text(encoding="utf-8")
        for word in ("UE5-Editor","nicht","1:1","Referenzbild"):
            self.assertIn(word,doc)

if __name__=="__main__": unittest.main()
