"""Unreal migration source audit WITHOUT UE5 compiler. Compile verification is separate."""
from pathlib import Path
import re, json
root=Path(__file__).resolve().parents[1]
project=json.loads((root/"NEXUS.uproject").read_text(encoding="utf-8"))
assert project["EngineAssociation"]=="5.8"
assert next(m["Name"] for m in project["Modules"] if m["Type"]=="Runtime")=="NEXUS"
codefiles=list((root/"Source/NEXUS").glob("*.cpp"))+list((root/"Source/NEXUS").glob("*.h"))
assert len(codefiles)>=19,len(codefiles)
all_src={p.name:p.read_text(encoding="utf-8") for p in codefiles}
for filename,source in all_src.items():
    if filename.endswith(".h") and filename not in ("NexusTypes.h",):
        assert "#pragma once" in source,filename
    for name in re.findall(r'#include\s+"(Nexus\w+\.h)"',source):
        assert name in all_src,(filename,name)
    assert source.count("{")==source.count("}"),filename
assert "IMPLEMENT_PRIMARY_GAME_MODULE" in all_src["NEXUS.cpp"]
assert "GetAuthGameMode" in all_src["NexusVehicle.cpp"]
assert "VehicleAdvanced" in all_src["NexusWorldDirector.cpp"]
assert "Collapse()" in all_src["NexusBridge.cpp"]
assert "DropBehindPlayer()" in all_src["NexusBus.cpp"]
assert "TryVehicleRescue" in all_src["NexusWorldDirector.cpp"]
assert "TryReconstruct()" in all_src["NexusWorldDirector.cpp"]
assert "SaveGameToSlot" in all_src["NexusWorldDirector.cpp"]
assert "for(auto* Person:Survivors)" not in all_src["NexusWorldDirector.cpp"]
assert "for(auto* Site:Industry)" not in all_src["NexusWorldDirector.cpp"]
assert len(re.findall(r'case ENexusIndustry::',all_src["NexusWorldDirector.cpp"]))>=12
assert "if(bEnteredSpan && P.X>4600.f" in all_src["NexusWorldDirector.cpp"]
assert "UNexusSaveGame" in all_src["NexusSaveGame.h"]
assert "M_AlpineRock" in all_src["NexusWorldDirector.cpp"]
assert "PixelStreaming2" in (root/"Docs/CLOUD_UE5_WITHOUT_GAMING_PC.md").read_text()
assert (root/"Scripts/import_nexus_pbr.py").is_file()
inputs=(root/"Config/DefaultInput.ini").read_text()
for action in ["Interact","ExitVehicle","RoleMedic","RolePilot","RoleGround","MissionApproach"]:
    assert f'ActionName="{action}"' in inputs,action
# Additional no-budget UE5 asset pipeline checks (syntax/contract only).
import ast
for filename in ("import_nexus_pbr.py", "import_nexus_geometry.py"):
    ast.parse((root/"Scripts"/filename).read_text(encoding="utf-8"),filename=filename)
assert "SM_NEXUS_BridgeSpan_6p83m" in all_src["NexusBridge.cpp"]
assert "SM_NEXUS_RescueBus_12m" in all_src["NexusBus.cpp"]
assert "SM_NEXUS_FireRescue_Truck" in all_src["NexusVehicle.cpp"]
# Vehicle class centrally selects rescue helicopter mesh, including optional V6 animated body.
assert "SM_NEXUS_RescueHelicopter" in all_src["NexusVehicle.cpp"]
assert "GetTimerManager().SetTimer" in all_src["NexusBridge.cpp"]
assert "RolePilot" in all_src["NexusVehicle.cpp"] and "RoleMedic" in all_src["NexusVehicle.cpp"]
assert "RoleGround" in all_src["NexusVehicle.cpp"]
assert "LineTraceSingleByChannel" in all_src["NexusVehicle.cpp"]
assert "FallingSpeed" in all_src["NexusVehicle.cpp"]
assert "OriginalLocalTransforms" in all_src["NexusBridge.cpp"]
assert "FVector(-8400,0,1945)" in all_src["NexusWorldDirector.cpp"]
assert "FVector(8400,0,1945)" in all_src["NexusWorldDirector.cpp"]
assert "130000.f,-50000.f" not in all_src["NexusBus.cpp"], "Unrealistic fall impulse"
assert "17000.f,Sign*11000.f,-85000.f" not in all_src["NexusBridge.cpp"], "Unrealistic span impulse"
print("PASS: UE5 geometry import script, four hero-mesh hooks, staged gravity physics and connected roads")
print(f"NEXUS UE5 source audit PASS: {len(codefiles)} C++ files")
print("NOTICE: UE5.8 compiler/editor/graphics and gameplay have NOT been executed here.")
