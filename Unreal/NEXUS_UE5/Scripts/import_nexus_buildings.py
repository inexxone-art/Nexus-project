"""Run in UE5 Editor Python console after generating building GLBs.
Preserves existing assets; no destructive overwrite.
"""
from pathlib import Path
import unreal

SOURCE=Path(unreal.Paths.project_content_dir())/"SourceArt"/"Geometry"/"Buildings"
TARGET="/Game/AAA/Geometry/Buildings"
LIB=unreal.EditorAssetLibrary
TOOLS=unreal.AssetToolsHelpers.get_asset_tools()

def main():
    glbs=sorted(SOURCE.glob("B*.glb"))
    if not glbs:raise RuntimeError("No building GLBs: generate offline first")
    imported=0
    for path in glbs:
        asset=f"{TARGET}/{path.stem}"
        if LIB.does_asset_exist(asset):
            unreal.log("NEXUS existing mesh kept: "+asset)
            continue
        task=unreal.AssetImportTask()
        task.set_editor_property("filename",str(path))
        task.set_editor_property("destination_path",TARGET)
        task.set_editor_property("destination_name",path.stem)
        task.set_editor_property("automated",True)
        task.set_editor_property("replace_existing",False)
        task.set_editor_property("save",True)
        TOOLS.import_asset_tasks([task])
        meshes=[LIB.load_asset(str(x)) for x in task.get_editor_property("imported_object_paths") or []]
        if not any(isinstance(m,unreal.StaticMesh) for m in meshes):
            raise RuntimeError("Import failed: "+str(path))
        imported+=1
    unreal.log(f"NEXUS building geometry imported: {imported}, preserved existing")
if __name__=="__main__":main()
