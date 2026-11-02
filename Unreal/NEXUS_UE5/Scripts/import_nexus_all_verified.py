"""Run this inside Unreal Engine 5.8 Python Editor Script Plugin.

One entrypoint for the six verified NEXUS Library source bundles.
Imports only present mesh/texture/CC0 assets using existing project scripts,
never fabricates missing story/planet/character content, never downloads files.
The 16-bit Landscape heightmap stays a MANUAL Landscape Editor step.
"""
from pathlib import Path
import json
import traceback
import runpy
import unreal

PROJECT = Path(unreal.Paths.project_dir())
CONTENT = Path(unreal.Paths.project_content_dir())
SCRIPTS = PROJECT / "Scripts"
SOURCE = CONTENT / "SourceArt"
REPORT = SOURCE / "nexus_verified_import_report.json"

def inspect_sources():
    groups = {
        "pbr_png": list((SOURCE/"PBR").glob("*.png")),
        "hero_glb": list((SOURCE/"Geometry"/"Hero").glob("*.glb")),
        "terrain_glb": list((SOURCE/"Geometry"/"TerrainTiles").glob("*.glb")),
        "foliage_glb": list((SOURCE/"Geometry"/"Foliage").glob("*.glb")),
        "cc0_scanned_glb": list((SOURCE/"Geometry"/"CC0").glob("SM_NEXUS_ScannedRockSet.glb")),
        "landscape_heightmap": list((SOURCE/"Heightmap").glob("*2017x2017_16bit.png")),
    }
    return {k:len(v) for k,v in groups.items()}

def main():
    counts = inspect_sources()
    unreal.log("NEXUS verified sources located: " + str(counts))
    required={"pbr_png":72,"hero_glb":4,"terrain_glb":9,"foliage_glb":5,
              "cc0_scanned_glb":1,"landscape_heightmap":1}
    for key,want in required.items():
        if counts.get(key,0)<want:
            unreal.log_warning(f"NEXUS {key}: {counts.get(key,0)}/{want}; import may be incomplete.")
    state=[]
    for name in ("import_nexus_pbr.py","import_nexus_geometry.py","import_nexus_cc0_scans.py"):
        file=SCRIPTS/name
        if not file.is_file():
            state.append({"script":name,"status":"MISSING_SCRIPT"})
            continue
        try:
            runpy.run_path(str(file),run_name="__main__")
            state.append({"script":name,"status":"EXECUTED"})
        except Exception as exc:
            unreal.log_error(f"NEXUS import {name}: {exc}")
            unreal.log_error(traceback.format_exc())
            state.append({"script":name,"status":"FAILED","reason":str(exc)})
    REPORT.parent.mkdir(parents=True,exist_ok=True)
    REPORT.write_text(json.dumps({
        "state":"UE_EDITOR_IMPORT_REPORT_NOT_A_GAMEPLAY_QUALITY_CERTIFICATE",
        "source_counts":counts,"script_runs":state,
        "landscape_import":"MANUAL_LANDSCAPE_EDITOR_REQUIRED",
        "expected_asset_slots_unfulfilled":"See Content/Data/nexus_user_vision_2026_11.json"
    },indent=2,ensure_ascii=False),encoding="utf-8")
    unreal.log("NEXUS verification report written: " + str(REPORT))
    if any(x["status"]=="FAILED" for x in state):
        raise RuntimeError("One or more NEXUS asset pipelines failed; read the Editor log and report.")
    unreal.log_warning("NEXUS: Real editor render, map/mesh placement and PBR checks still required.")

if __name__=="__main__":
    main()
