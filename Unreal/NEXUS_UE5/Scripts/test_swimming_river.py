"""No Unreal binary is available: verify the swimming and salvage contracts.
These are source-level/offline tests, not an in-engine water simulation.
"""
import ast
from pathlib import Path
import unittest

ROOT=Path(__file__).resolve().parents[1]
SRC=ROOT/"Source/NEXUS"
def read(name):return (SRC/name).read_text(encoding="utf-8")

class NEXUSRiverSwimChecks(unittest.TestCase):
    def test_morphology_has_colliding_bed_and_unblocked_surface(self):
        river=read("NexusAlpineRiver.cpp")
        self.assertIn("Riverbed=CreateDefaultSubobject",river)
        self.assertIn("RiverSurface->SetCastShadow(false)",river)
        self.assertIn("Ground->SetCollisionEnabled(ECollisionEnabled::QueryAndPhysics)",river)
        self.assertIn("const bool bCollide=(Mode!=0)",river)
        self.assertIn("const float BankRise=EdgeDepth+320.f",river)
        self.assertIn("FMath::Pow(BankF,.24f)",river)
        self.assertIn("FMath::Pow(BankF,1.85f)",river)
        self.assertIn("CrossProduct(Across,Along)",river)
        self.assertIn("ErodingOuterSide(Alpha)",river)
        self.assertIn("FMath::Lerp(.55f,1.5f,Outer)",river)

    def test_swimming_controls_oxygen_and_local_postprocess(self):
        character=read("NexusExplorer.cpp")
        header=read("NexusExplorer.h")
        keys=(ROOT/"Config/DefaultInput.ini").read_text()
        self.assertIn('ActionName="SwimDescend",Key=LeftControl',keys)
        self.assertIn('Input->BindAction(TEXT("Jump"),IE_Pressed',character)
        self.assertIn('Input->BindAction(TEXT("SwimDescend"),IE_Pressed',character)
        self.assertIn("ServerSwimVertical_Implementation",character)
        self.assertIn("GetScaledCapsuleHalfHeight()",character)
        self.assertIn("MOVE_Flying",character)
        self.assertIn("MOVE_Falling",character)
        self.assertIn("Health=FMath::Max(0.f,Health-14.f*Dt)",character)
        self.assertIn("OxygenSeconds=FMath::Max(0.f,OxygenSeconds-Dt)",character)
        self.assertIn("OnRep_SwimState",header)
        self.assertIn("PostProcessSettings.SceneColorTint",character)
        self.assertIn("bHeadUnderwater?0.85f:0.f",character)

    def test_underwater_recorder_is_a_real_mission_branch(self):
        world=read("NexusWorldDirector.cpp")
        evidence=read("NexusUnderwaterEvidence.cpp")
        save=read("NexusSaveGame.h")
        for part in ("ANexusUnderwaterEvidence::StaticClass()",
                     "River->SampleWater(FVector(0.f,0.f,0.f)",
                     "if(Evidence) Evidence->SetAvailable(true)",
                     "Explorer->bIsSwimming && Explorer->bHeadUnderwater",
                     "FVector::Dist(P,Evidence->GetActorLocation())<260.f",
                     'Story->CompleteObjective(TEXT("investigate_saboteur"))',
                     "Evidence->Recover()",
                     "Save->bEvidenceRecovered=",
                     "if(Save->bEvidenceRecovered) Evidence->Recover()"):
            self.assertIn(part,world)
        self.assertIn("DOREPLIFETIME(ANexusUnderwaterEvidence,bRecovered)",evidence)
        self.assertIn("DOREPLIFETIME(ANexusUnderwaterEvidence,bAvailable)",evidence)
        self.assertIn("bEvidenceRecovered = false",save)

    def test_erosion_deposition_material_generation(self):
        path=ROOT/"Scripts/create_riverbank_material.py"
        code=path.read_text()
        ast.parse(code,filename=path.name)
        self.assertIn("MaterialExpressionVertexColor",code)
        self.assertIn("MaterialExpressionLinearInterpolate",code)
        self.assertIn("M_NexusRiverbank",code)
        river=read("NexusAlpineRiver.cpp")
        self.assertIn("M_NexusRiverbank",river)
        self.assertIn("FColor(199,157,96,255)",river)
        self.assertIn("FColor(79,87,91,255)",river)

    def test_bridge_crosses_water_and_no_box_river_floor(self):
        river=read("NexusAlpineRiver.cpp")
        world=read("NexusWorldDirector.cpp")
        self.assertIn('FMath::Lerp(-9200.f,9200.f,T)',river)
        self.assertIn('Position.Y < -9200.f',river)
        self.assertNotIn('TEXT("RiverBase")',world)
        self.assertIn('TEXT("WestCliffFace")',world)
        self.assertIn('TEXT("EastCliffFace")',world)

if __name__=="__main__":
    unittest.main()
