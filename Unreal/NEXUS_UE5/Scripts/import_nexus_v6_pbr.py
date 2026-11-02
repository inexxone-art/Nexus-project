"""Unreal Editor 5.8: Import 14 original procedural PBR material families.

PBR_V6 can be 1K/2K package with the same mesh-independent paths.
No overwrites; maps are authored approximations, not real-world photo scans.
"""
from pathlib import Path
import hashlib,json
import unreal

CONTENT=Path(unreal.Paths.project_content_dir())
SOURCE=CONTENT/"SourceArt"/"PBR_V6"
MANIFEST=SOURCE/"NEXUS_V6_PBR_MANIFEST.json"
ASSETS=unreal.AssetToolsHelpers.get_asset_tools()
LIB=unreal.EditorAssetLibrary
MATS=unreal.MaterialEditingLibrary
TEX="/Game/AAA/TexturesV6"
DEST="/Game/AAA/MaterialsV6"

PROP={
    "albedo":unreal.MaterialProperty.MP_BASE_COLOR,
    "normal":unreal.MaterialProperty.MP_NORMAL,
    "roughness":unreal.MaterialProperty.MP_ROUGHNESS,
    "metallic":unreal.MaterialProperty.MP_METALLIC,
    "ao":unreal.MaterialProperty.MP_AMBIENT_OCCLUSION,
}

def import_texture(name,channel,entry):
    source=SOURCE/entry["filename"]
    if not source.is_file():raise FileNotFoundError(source)
    digest=hashlib.sha256(source.read_bytes()).hexdigest()
    if digest!=entry["sha256"]:raise ValueError("Tampered or incomplete PBR source: "+source.name)
    asset_name="T_V6_"+name+"_"+channel
    asset_path=TEX+"/"+asset_name
    if LIB.does_asset_exist(asset_path):
        return LIB.load_asset(asset_path)
    task=unreal.AssetImportTask()
    task.set_editor_property("filename",str(source))
    task.set_editor_property("destination_path",TEX)
    task.set_editor_property("destination_name",asset_name)
    task.set_editor_property("automated",True)
    task.set_editor_property("replace_existing",False)
    task.set_editor_property("save",True)
    ASSETS.import_asset_tasks([task])
    obj=LIB.load_asset(asset_path)
    if not isinstance(obj,unreal.Texture2D):raise RuntimeError("Texture import failed: "+str(source))
    obj.set_editor_property("srgb",channel=="albedo")
    if channel=="normal":
        obj.set_editor_property("compression_settings",unreal.TextureCompressionSettings.TC_NORMALMAP)
    LIB.save_loaded_asset(obj)
    return obj

def make_material(row):
    name=row["name"]
    target=DEST+"/M_V6_"+name
    if LIB.does_asset_exist(target):
        unreal.log("NEXUS: existing material preserved "+target)
        return
    f=unreal.MaterialFactoryNew()
    material=ASSETS.create_asset("M_V6_"+name,DEST,unreal.Material,f)
    if material is None:raise RuntimeError("Unable to create material "+name)
    channels=row["maps"]
    for i,(channel,property_id) in enumerate(PROP.items()):
        tex=import_texture(name,channel,channels[channel])
        node=MATS.create_material_expression(material,unreal.MaterialExpressionTextureSample,-480,i*210)
        node.set_editor_property("texture",tex)
        output="RGB" if channel in ("albedo","normal") else "R"
        MATS.connect_material_property(node,output,property_id)
    # Height map is imported for parallax/material experimentation, not
    # plugged into Displacement blindly (engine/tessellation dependent).
    import_texture(name,"height",channels["height"])
    MATS.recompile_material(material)
    LIB.save_loaded_asset(material)
    unreal.log("NEXUS V6 PBR: "+target)

def main():
    data=json.loads(MANIFEST.read_text(encoding="utf-8"))
    rows=data["materials"]
    if data["schema_version"]!=1 or len(rows)!=14:
        raise ValueError("Expected 14 approved NEXUS procedural PBR sets")
    for row in rows:make_material(row)
    unreal.log_warning("NEXUS: Assign imported PBR materials to UV-mapped mesh slots "
        "and validate normal/lighting in Unreal Editor; not automatic photorealism.")

if __name__=="__main__":
    main()
