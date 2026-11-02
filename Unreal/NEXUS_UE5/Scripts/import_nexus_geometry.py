"""Run inside UE 5.8 Editor: Tools > Execute Python Script.
Copy 4 hero GLBs to Content/SourceArt/Geometry/Hero and 9 terrain GLBs
to Content/SourceArt/Geometry/TerrainTiles before running."""
from pathlib import Path
import unreal

BASE = Path(unreal.Paths.project_content_dir()) / "SourceArt" / "Geometry"
TOOLS = unreal.AssetToolsHelpers.get_asset_tools()
LIB = unreal.EditorAssetLibrary
HERO = "/Game/AAA/Geometry/Hero"
TERRAIN = "/Game/AAA/Geometry/TerrainPreview"
FOLIAGE = "/Game/AAA/Geometry/Foliage"

def import_glb(file, destination):
    name = file.stem
    target = f"{destination}/{name}"
    if LIB.does_asset_exist(target):
        unreal.log(f"NEXUS: existing asset kept: {target}")
        return LIB.load_asset(target)
    task = unreal.AssetImportTask()
    task.set_editor_property("filename", str(file))
    task.set_editor_property("destination_path", destination)
    task.set_editor_property("destination_name", name)
    task.set_editor_property("automated", True)
    task.set_editor_property("replace_existing", False)
    task.set_editor_property("save", True)
    TOOLS.import_asset_tasks([task])
    assets = [LIB.load_asset(str(x)) for x in (task.get_editor_property("imported_object_paths") or [])]
    mesh = next((x for x in assets if isinstance(x, unreal.StaticMesh)), None)
    if mesh is None:
        mesh = LIB.load_asset(target)
    if not isinstance(mesh, unreal.StaticMesh):
        raise RuntimeError(f"No StaticMesh imported from {file.name}")
    if destination == HERO:
        try:
            unreal.EditorStaticMeshLibrary.add_simple_collisions(
                mesh, unreal.ScriptingCollisionShapeType.BOX)
            LIB.save_loaded_asset(mesh)
        except Exception as exc:
            unreal.log_warning(f"Collision setup must be checked manually: {file.name}: {exc}")
    unreal.log(f"NEXUS: imported {file.name} as {mesh.get_path_name()}")
    return mesh

def main():
    heroes = sorted((BASE/"Hero").glob("*.glb"))
    tiles = sorted((BASE/"TerrainTiles").glob("*.glb"))
    foliage = sorted((BASE/"Foliage").glob("*.glb"))
    if len(heroes) != 4 or len(tiles) != 9:
        raise RuntimeError(f"Expected 4 hero + 9 terrain GLBs, got {len(heroes)} and {len(tiles)}")
    for src in heroes: import_glb(src, HERO)
    for src in tiles: import_glb(src, TERRAIN)
    for src in foliage: import_glb(src, FOLIAGE)
    unreal.log("13 original meshes imported. Hero models should auto-load in NEXUS C++ if package names match.")
    unreal.log_warning("TerrainPreview is NOT a physics Landscape; never overlap a Landscape with the same GLBs.")

if __name__ == "__main__":
    main()
