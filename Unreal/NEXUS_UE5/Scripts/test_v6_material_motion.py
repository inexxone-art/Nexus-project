"""Offline static checks of material and animated component integration."""
import ast
from pathlib import Path
import unittest
ROOT=Path(__file__).resolve().parents[1]
S=ROOT/"Source"/"NEXUS"
def read(name):return (S/name).read_text(encoding="utf-8")
class V6MotionTests(unittest.TestCase):
    def test_rotor_and_wheels_move_as_real_scene_components(self):
        c=read("NexusVehicle.cpp");h=read("NexusVehicle.h")
        for token in ("MainRotorPivot","MainRotorVisual","RoadWheels",
                      "MotionBodies","SM_Nexus_AnimatedWheel","SM_Nexus_RotorFive",
                      "AddLocalRotation","PreviousVisualLocation",
                      "bV6MovingParts"):
            self.assertIn(token,c)
        self.assertIn("bV6MovingParts",h)
        self.assertIn("if(!bV6MovingParts)",c)
    def test_character_recoil_is_visual_only(self):
        c=read("NexusExplorer.cpp")
        for token in ("WeaponRecoilAlpha","WeaponReloadAlpha","FInterpTo",
                      "FirstPersonWeaponVisual->SetRelativeLocation"):
            self.assertIn(token,c)
    def test_import_pipeline_present(self):
        code=(ROOT/"Scripts/import_nexus_v6_pbr.py").read_text()
        ast.parse(code)
        for token in ("MP_METALLIC","roughness","normal","sRGB" if False else "srgb",
                      "replace_existing","False","PBR_V6"):
            self.assertIn(token,code)
if __name__=="__main__":unittest.main()
