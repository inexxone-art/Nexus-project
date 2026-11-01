"""
Run INSIDE Unreal Editor 5.8 with Python Editor Script Plugin enabled:
  Tools > Execute Python Script > Scripts/import_nexus_pbr.py

Imports original project images from Content/SourceArt/PBR (PNG) and
creates Unreal material assets wired to base color, normal, roughness and AO.
Normal/roughness/AO are artist-estimated maps, NOT photogrammetry scans.
"""
import os
from pathlib import Path
import unreal

ROOT = Path(unreal.Paths.project_content_dir()) / "SourceArt" / "PBR"
TOOLS = unreal.AssetToolsHelpers.get_asset_tools()
LIB = unreal.EditorAssetLibrary
EDIT = unreal.MaterialEditingLibrary
DEST_TEX = "/Game/AAA/Textures"
DEST_MAT = "/Game/AAA/Materials"

def import_texture(path, category, channel):
    asset_name = f"T_{category}_{channel}"
    package = f"{DEST_TEX}/{asset_name}"
    if LIB.does_asset_exist(package):
        texture = LIB.load_asset(package)
    else:
        task = unreal.AssetImportTask()
        task.set_editor_property("filename", str(path))
        task.set_editor_property("destination_path", DEST_TEX)
        task.set_editor_property("destination_name", asset_name)
        task.set_editor_property("replace_existing", True)
        task.set_editor_property("automated", True)
        task.set_editor_property("save", True)
        TOOLS.import_asset_tasks([task])
        texture = LIB.load_asset(package)
    if texture is None:
        raise RuntimeError(f"Texture import failed: {path}")
    texture.set_editor_property("srgb", channel == "albedo")
    if channel == "normal":
        texture.set_editor_property("compression_settings", unreal.TextureCompressionSettings.TC_NORMALMAP)
    LIB.save_loaded_asset(texture)
    return texture

def add_map(material, texture, material_property, x, y):
    sample = EDIT.create_material_expression(material, unreal.MaterialExpressionTextureSample, x, y)
    sample.set_editor_property("texture", texture)
    if sample.texture is None:
        raise RuntimeError("Material texture node failed")
    channel = "R" if material_property in (
        unreal.MaterialProperty.MP_ROUGHNESS,
        unreal.MaterialProperty.MP_AMBIENT_OCCLUSION,
    ) else "RGB"
    EDIT.connect_material_property(sample, channel, material_property)

def generate_material(category, textures):
    path = f"{DEST_MAT}/M_{category}"
    if LIB.does_asset_exist(path):
        mat = LIB.load_asset(path)
        # Re-running does not destroy materials artists have already customized.
        unreal.log(f"NEXUS: existing material preserved: {path}")
        return mat
    factory = unreal.MaterialFactoryNew()
    mat = TOOLS.create_asset(f"M_{category}", DEST_MAT, unreal.Material, factory)
    if mat is None:
        raise RuntimeError(f"Material creation failed: {category}")
    if "albedo" in textures:
        add_map(mat, textures["albedo"], unreal.MaterialProperty.MP_BASE_COLOR, -520, 0)
    if "normal" in textures:
        add_map(mat, textures["normal"], unreal.MaterialProperty.MP_NORMAL, -520, 240)
    if "roughness" in textures:
        add_map(mat, textures["roughness"], unreal.MaterialProperty.MP_ROUGHNESS, -520, 470)
    if "ao" in textures:
        add_map(mat, textures["ao"], unreal.MaterialProperty.MP_AMBIENT_OCCLUSION, -520, 690)
    EDIT.recompile_material(mat)
    LIB.save_loaded_asset(mat)
    unreal.log(f"NEXUS material ready: {path}")
    return mat

def main():
    if not ROOT.is_dir():
        raise RuntimeError(f"SourceArt missing! Extract COMPLETE ZIP. Expected: {ROOT}")
    groups = {}
    for item in ROOT.glob("*.png"):
        if "_" not in item.stem:
            continue
        category, channel = item.stem.rsplit("_", 1)
        if channel not in ("albedo", "normal", "roughness", "ao"):
            continue
        groups.setdefault(category, {})[channel] = item
    if not groups:
        raise RuntimeError("No PBR maps found in SourceArt/PBR")
    for category, files in sorted(groups.items()):
        textures = {channel: import_texture(path, category, channel)
                    for channel, path in files.items()}
        generate_material(category, textures)
    unreal.log(f"NEXUS UE5 imported {len(groups)} complete material groups.")

if __name__ == "__main__":
    main()
