"""Editor-only import for 28 validated NEXUS V5 GLB prototype meshes.

Extract the ZIP at the GitHub repository root; then in Unreal 5.8:
Tools > Execute Python Script > Scripts/import_nexus_v5_assets.py
Source Art files live under Content/SourceArt/NexusImports/<category>/.
This program NEVER downloads art, silently overwrites .uasset or claims a build.
"""
from pathlib import Path
import hashlib
import json
import unreal

PROJECT=Path(unreal.Paths.project_dir())
CONTENT=Path(unreal.Paths.project_content_dir())
SOURCE=CONTENT/"SourceArt"/"NexusImports"
REGISTRY=CONTENT/"Data"/"nexus_v5_asset_registry.json"
MANIFEST=SOURCE/"MANIFEST.json"
RESULT=SOURCE/"NEXUS_V5_EDITOR_IMPORT_REPORT.json"
DEST_BY_CATEGORY={
    "vehicles":"/Game/AAA/Geometry/Fleet",
    "props":"/Game/AAA/Geometry/Props",
    "architecture":"/Game/AAA/Geometry/StoryAreas",
}
TOOLS=unreal.AssetToolsHelpers.get_asset_tools()
LIB=unreal.EditorAssetLibrary

def read_manifest():
    if not MANIFEST.exists():
        raise RuntimeError(f"NEXUS V5 downloaded archive missing: {MANIFEST}")
    info=json.loads(MANIFEST.read_text(encoding="utf-8"))
    return {row["path"]:row for row in info["assets"]}

def import_entry(row,checksum):
    source=row["source_relpath"]
    if source!=row["category"]+"/"+row["filename"]:
        raise ValueError("Invalid source path")
    category=row["category"]
    if category not in DEST_BY_CATEGORY or row["destination"]!=DEST_BY_CATEGORY[category]:
        raise ValueError("Unapproved Unreal asset destination")
    path=SOURCE/source
    if not path.is_file():
        return {"id":row["id"],"status":"MISSING_SOURCE"}
    actual_sha=hashlib.sha256(path.read_bytes()).hexdigest()
    if actual_sha!=checksum:
        return {"id":row["id"],"status":"CHECKSUM_MISMATCH"}
    asset_name=Path(row["filename"]).stem
    package=row["destination"]+"/"+asset_name
    if LIB.does_asset_exist(package):
        return {"id":row["id"],"status":"EXISTING_PRESERVED","asset":package}
    task=unreal.AssetImportTask()
    task.set_editor_property("filename",str(path))
    task.set_editor_property("destination_path",row["destination"])
    task.set_editor_property("destination_name",asset_name)
    task.set_editor_property("replace_existing",False)
    task.set_editor_property("automated",True)
    task.set_editor_property("save",True)
    TOOLS.import_asset_tasks([task])
    listed=task.get_editor_property("imported_object_paths") or []
    meshes=[LIB.load_asset(str(p)) for p in listed]
    mesh=next((m for m in meshes if isinstance(m,unreal.StaticMesh)),None)
    if mesh is None:
        mesh=LIB.load_asset(package)
    if not isinstance(mesh,unreal.StaticMesh):
        return {"id":row["id"],"status":"IMPORT_DID_NOT_PRODUCE_STATIC_MESH"}
    if category=="vehicles":
        # Simple box collision for arcade prototype only. Check hero collision!
        try:
            unreal.EditorStaticMeshLibrary.add_simple_collisions(mesh,unreal.ScriptingCollisionShapeType.BOX)
            LIB.save_loaded_asset(mesh)
        except Exception as exc:
            unreal.log_warning("NEXUS vehicle collision must be authored manually: "+str(exc))
    if category=="architecture":
        # Complex-as-simple or custom multi-hull collision MUST be authored in UE5.
        # A single auto-convex box would block its walkable doorway/interior.
        unreal.log_warning("NEXUS building import requires per-poly/custom doorway collision: "+mesh.get_name())
    if not LIB.does_asset_exist(package):
        unreal.log_warning("NEXUS importer generated different Unreal asset path: "+str(mesh.get_path_name()))
    return {"id":row["id"],"status":"IMPORTED","asset":mesh.get_path_name()}

def main():
    catalog=json.loads(REGISTRY.read_text(encoding="utf-8"))
    manifests=read_manifest()
    if catalog["asset_count"]!=28 or len(catalog["assets"])!=28:
        raise ValueError("Expected exactly 28 independently generated V5 assets")
    results=[]
    for asset in catalog["assets"]:
        ref=manifests.get(asset["source_relpath"])
        if not ref:
            results.append({"id":asset["id"],"status":"NOT_LISTED_IN_GENERATED_MANIFEST"})
            continue
        try:
            row=import_entry(asset,ref["sha256"])
        except Exception as exc:
            row={"id":asset["id"],"status":"FAILED","reason":str(exc)}
        unreal.log("NEXUS V5: "+str(row))
        results.append(row)
    SOURCE.mkdir(parents=True,exist_ok=True)
    RESULT.write_text(json.dumps({"runtime":"UE_EDITOR_ONLY","results":results,
        "quality":"PROTOTYPE_NOT_PHOTOREAL",
        "manual_required":["custom interior collision","mesh scale","PBR materials",
                           "animation and rigging","vehicle handling QA","in-game screenshot"]},
        indent=2,ensure_ascii=False),encoding="utf-8")
    failures=[x for x in results if x["status"] not in ("IMPORTED","EXISTING_PRESERVED")]
    if failures:raise RuntimeError(f"NEXUS V5 {len(failures)} assets missing or failed; review {RESULT}")
    unreal.log("NEXUS V5 all assets imported as source geometry; ART/UE BUILD QA still pending.")

if __name__=="__main__":main()
