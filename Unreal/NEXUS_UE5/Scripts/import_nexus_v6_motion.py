"""Unreal Editor: import separable motion body/rotor/wheel assets.

Using original V5 geometry as starting source. Non-destructive to V5 imports.
The visible animations are performed by C++ component rotation at runtime.
"""
from pathlib import Path
import json,hashlib
import unreal

CONTENT=Path(unreal.Paths.project_content_dir())
SOURCE=CONTENT/"SourceArt"/"NexusV6Motion"
MANIFEST=SOURCE/"NEXUS_V6_MOTION_MESHES.json"
TOOLS=unreal.AssetToolsHelpers.get_asset_tools()
LIB=unreal.EditorAssetLibrary

def do_import(entry):
    relative=entry["path"]
    kind=entry["kind"]
    filename=Path(relative)
    if filename.is_absolute() or ".." in filename.parts or filename.suffix!=".glb":
        raise ValueError("Invalid motion import source path")
    if kind=="motion_body" and filename.parts[0]=="MotionBodies":
        destination="/Game/AAA/Geometry/MotionBodies"
    elif kind=="moving_part" and filename.parts[0]=="MovingParts":
        destination="/Game/AAA/Geometry/Animated"
    else: raise ValueError("Invalid motion mesh category")
    source=SOURCE/filename
    if not source.is_file():raise FileNotFoundError(source)
    if hashlib.sha256(source.read_bytes()).hexdigest()!=entry["sha256"]:
        raise ValueError("Motion mesh checksum mismatch: "+source.name)
    path=destination+"/"+filename.stem
    if LIB.does_asset_exist(path):
        unreal.log("NEXUS V6 existing mesh preserved: "+path)
        return
    task=unreal.AssetImportTask()
    task.set_editor_property("filename",str(source))
    task.set_editor_property("destination_path",destination)
    task.set_editor_property("destination_name",filename.stem)
    task.set_editor_property("automated",True)
    task.set_editor_property("replace_existing",False)
    task.set_editor_property("save",True)
    TOOLS.import_asset_tasks([task])
    obj=LIB.load_asset(path)
    if not isinstance(obj,unreal.StaticMesh):
        raise RuntimeError("Expected static motion component: "+str(source))
    unreal.log("NEXUS V6 imported: "+path)

def main():
    data=json.loads(MANIFEST.read_text(encoding="utf-8"))
    if len(data["assets"])!=14:raise ValueError("Expected 11 motion vehicle bodies + 3 moving parts")
    for row in data["assets"]:do_import(row)
    unreal.log_warning("NEXUS moving-parts geometry imported. Actual visual motion "
        "requires compiled updated C++ and animation playtest in editor.")

if __name__=="__main__":
    main()
