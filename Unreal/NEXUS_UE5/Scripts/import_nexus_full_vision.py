"""NEXUS full-vision asset import; run INSIDE Unreal Editor 5.8 Python.

Only imports existing approved meshes from:
  Content/SourceArt/NexusImports/<source_file> OR
  Content/SourceArt/NexusImports/<category>/<source_file>
Missing references are reported, never downloaded or invented.
No destructive overwrite and no fabrication of .uasset blueprints/vfx.
"""
from pathlib import Path
import json
import unreal

CONTENT = Path(unreal.Paths.project_content_dir()).resolve()
CATALOG = CONTENT / "Data" / "nexus_user_vision_2026_11.json"
SOURCE = CONTENT / "SourceArt" / "NexusImports"
REPORT = CONTENT / "SourceArt" / "NexusImports" / "nexus_import_report.json"
ALLOWED_EXTENSIONS = {".glb", ".gltf", ".fbx", ".obj"}
ALLOWED_CATEGORIES = {"hero", "terrain", "architecture", "characters", "vehicles",
                      "props", "industry"}
ALLOWED_ROOT = "/Game/AAA/Geometry/"

def candidate_paths(row):
    filename = row["source_file"]
    if Path(filename).name != filename or "/" in filename or "\\" in filename:
        raise ValueError("Unsafe asset filename: " + filename)
    return [SOURCE / filename, SOURCE / row["category"] / filename]

def is_allowed_destination(path):
    return path.startswith(ALLOWED_ROOT) or path == "/Game/AAA/Characters"

def import_one(row, assets, library):
    if row["category"] not in ALLOWED_CATEGORIES:
        return {"id": row["id"], "status": "MANUAL_UNREAL_ASSET", "reason": row["category"]}
    if not is_allowed_destination(row["destination"]):
        raise ValueError("Unsafe destination: " + row["destination"])
    paths = candidate_paths(row)
    filename = next((p for p in paths if p.is_file()), None)
    if filename is None:
        return {"id":row["id"],"status":"MISSING_SOURCE",
                "expected": [str(p.relative_to(CONTENT)) for p in paths]}
    if filename.suffix.lower() not in ALLOWED_EXTENSIONS:
        return {"id":row["id"],"status":"UNSUPPORTED_FORMAT"}
    path = row["destination"] + "/" + filename.stem
    if library.does_asset_exist(path):
        return {"id":row["id"],"status":"EXISTS_PRESERVED","path":path}
    task = unreal.AssetImportTask()
    task.set_editor_property("filename", str(filename))
    task.set_editor_property("destination_path", row["destination"])
    task.set_editor_property("destination_name", filename.stem)
    task.set_editor_property("automated", True)
    task.set_editor_property("replace_existing", False)
    task.set_editor_property("save", True)
    assets.import_asset_tasks([task])
    objects = task.get_editor_property("imported_object_paths") or []
    if not objects:
        return {"id":row["id"],"status":"FAILED","reason":"Unreal import returned no assets"}
    return {"id":row["id"],"status":"IMPORTED","objects":[str(p) for p in objects]}

def main():
    if not CATALOG.exists():
        raise FileNotFoundError(f"Missing NEXUS feature catalogue: {CATALOG}")
    data=json.loads(CATALOG.read_text(encoding="utf-8"))
    if data["schema_version"]!=1:
        raise ValueError("Unsupported full vision schema")
    tool = unreal.AssetToolsHelpers.get_asset_tools()
    library = unreal.EditorAssetLibrary
    results=[]
    for slot in data["asset_slots"]:
        try:
            result=import_one(slot,tool,library)
        except Exception as exc:
            result={"id":slot["id"],"status":"FAILED","reason":str(exc)}
        results.append(result)
        unreal.log("NEXUS " + str(result))
    SOURCE.mkdir(parents=True,exist_ok=True)
    REPORT.write_text(json.dumps({"source_catalogue":CATALOG.name,
        "asset_slots_total":len(results),"results":results},indent=2,ensure_ascii=False),encoding="utf-8")
    states={}
    for result in results:
        states[result["status"]]=states.get(result["status"],0)+1
    unreal.log("NEXUS importer summary: " + str(states))
    if states.get("FAILED",0):
        unreal.log_warning("NEXUS: Some imports failed. Check the report; never treat missing assets as ready.")
    return results

if __name__=="__main__":
    main()
