"""UE5 Editor Python utility — import real licensed rock scan from Poly Haven.
Copy extracted photo-scan ZIP to Content/SourceArt/Geometry/CC0/.
Required: SM_NEXUS_ScannedRockSet.glb + CC0_PROVENANCE.json.
This is a real PBR textured model, no synthetic gameplay image.
"""
from pathlib import Path
import json
import unreal

SOURCE=Path(unreal.Paths.project_content_dir())/"SourceArt"/"Geometry"/"CC0"
GLB=SOURCE/"SM_NEXUS_ScannedRockSet.glb"
PROVENANCE=SOURCE/"CC0_PROVENANCE.json"
DEST="/Game/AAA/Geometry/CC0"
EXPECTED=DEST+"/SM_NEXUS_ScannedRockSet"

def main():
    if not GLB.is_file() or not PROVENANCE.is_file():
        raise RuntimeError("Extract the complete NEXUS CC0 photo-scan zip into Content/SourceArt/Geometry/CC0")
    record=json.loads(PROVENANCE.read_text(encoding="utf-8"))
    if record.get("rights")!="CC0-1.0" or record.get("source")!="https://polyhaven.com":
        raise RuntimeError("Asset licence/provenance does not match allowed CC0 origin")
    if unreal.EditorAssetLibrary.does_asset_exist(EXPECTED):
        unreal.log(f"NEXUS scanned asset already installed: {EXPECTED}")
        return
    task=unreal.AssetImportTask()
    task.set_editor_property("filename",str(GLB))
    task.set_editor_property("destination_path",DEST)
    task.set_editor_property("destination_name","SM_NEXUS_ScannedRockSet")
    task.set_editor_property("automated",True)
    task.set_editor_property("replace_existing",False)
    task.set_editor_property("save",True)
    unreal.AssetToolsHelpers.get_asset_tools().import_asset_tasks([task])
    assets=unreal.EditorAssetLibrary.list_assets(DEST,recursive=True,include_folder=False)
    meshes=[a for a in assets
        if isinstance(unreal.EditorAssetLibrary.load_asset(a),unreal.StaticMesh)]
    if not meshes:
        raise RuntimeError("No StaticMesh imported from scanned 3D rock set")
    if not unreal.EditorAssetLibrary.does_asset_exist(EXPECTED):
        candidate=next((a for a in meshes if "ScannedRock" in a),meshes[0])
        if candidate!=EXPECTED:
            unreal.EditorAssetLibrary.rename_asset(candidate,EXPECTED)
    unreal.log(f"NEXUS REAL SCAN READY: {EXPECTED} (Kless Gyzen, Poly Haven, CC0)")
    unreal.log_warning("Inspect materials, scale, collisions and Nanite before using this mesh in production.")

if __name__=="__main__":
    main()
