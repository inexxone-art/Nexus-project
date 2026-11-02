"""Fictional inventory progression + practice-only damage (offline source contracts)."""
from pathlib import Path
import unittest
ROOT=Path(__file__).resolve().parents[1]
SRC=ROOT/"Source"/"NEXUS"
def src(p):return (SRC/p).read_text(encoding="utf-8")
class WeaponProgressionTests(unittest.TestCase):
    def test_conventional_first_and_alien_locked(self):
        cpp=src("NexusWeaponComponent.cpp")
        for name in ('TEXT("Pistole")','TEXT("Karabiner")','TEXT("Praezisionsgewehr")',
                     'TEXT("Alien-Puls")','TEXT("Plasmabogen")'):
            self.assertIn(name,cpp)
        self.assertIn("One.bUnlocked=!NexusCombat::Settings[I].Future",cpp)
        self.assertIn("bSciFiUnlocked",cpp)
        self.assertIn("if(!State.bUnlocked || (EquippedIndex>=4 && !bSciFiUnlocked)",cpp)
    def test_server_authority_and_no_pvp(self):
        cpp=src("NexusWeaponComponent.cpp")
        for name in ("ServerFire_Implementation","NextAllowedShot","State.InMagazine",
                     "Target->ReceivePracticeHit","COND_OwnerOnly","ServerReload_Implementation"):
            self.assertIn(name,cpp)
        self.assertNotIn("ApplyDamage(",cpp)
        self.assertNotIn("ACharacter* Victim",cpp)
    def test_unlock_requires_staged_research_cost_and_sample(self):
        world=src("NexusWorldDirector.cpp")
        for name in ("TryResearchSciFi(","meteor_research","military_training_completed",
                     'Stock.Get(TEXT("MeteorOre"))<3',"Credits<950",
                     "Stock.Add(TEXT(\"MeteorOre\"),-3)","UnlockSciFiFromResearch"):
            self.assertIn(name,world)
        self.assertIn('Hits>=5',src("NexusPracticeTarget.cpp"))
        self.assertIn("DOREPLIFETIME(ANexusPracticeTarget,Hits)",src("NexusPracticeTarget.cpp"))
    def test_player_controls_and_visual_paths(self):
        cpp=src("NexusExplorer.cpp")
        inp=(ROOT/"Config"/"DefaultInput.ini").read_text()
        for token in ("WeaponFire","WeaponCycle","WeaponReload","ResearchSciFi"):
            self.assertIn('ActionName="'+token+'"',inp)
            self.assertIn('TEXT("'+token+'")',cpp)
        for token in ("FirstPersonWeaponVisual","ThirdPersonWeaponVisual","RefreshWeaponVisual"):
            self.assertIn(token,cpp)
        self.assertIn("GetMagazineAmmo()",src("NexusHUD.cpp"))
if __name__=="__main__":unittest.main()
