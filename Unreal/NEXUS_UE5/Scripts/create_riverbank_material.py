"""UE 5.8 Editor: build an actual geometry-aware riverbank shader.
Light yellow sediment vs dark fractured cliff is selected by mesh vertex
colors written by ANexusAlpineRiver::CreateGrid. This is a procedural
placeholder, not a scanned AAA material or an artist-made layer blend.
"""
import unreal

TOOLS = unreal.AssetToolsHelpers.get_asset_tools()
EDIT = unreal.MaterialEditingLibrary
LIB = unreal.EditorAssetLibrary
DEST = "/Game/AAA/Materials"
NAME = "M_NexusRiverbank"

def expr(material, type_, x, y):
    node = EDIT.create_material_expression(material, type_, x, y)
    if node is None:
        raise RuntimeError("Failed creating Unreal expression")
    return node

def constant(material, rgba, x, y):
    node = expr(material, unreal.MaterialExpressionConstant3Vector, x, y)
    node.set_editor_property("constant", unreal.LinearColor(*rgba, 1))
    return node

def main():
    path = f"{DEST}/{NAME}"
    if LIB.does_asset_exist(path):
        unreal.log("NEXUS: preserving artist modifications in existing riverbank shader")
        return
    material = TOOLS.create_asset(NAME, DEST, unreal.Material, unreal.MaterialFactoryNew())
    if not material:
        raise RuntimeError("Could not create riverbank material")
    material.set_editor_property("two_sided", True)
    rock = constant(material, (.14,.15,.16), -720, -240)
    sand = constant(material, (.48,.36,.21), -720, -40)
    vertex = expr(material, unreal.MaterialExpressionVertexColor, -720, 180)
    red = expr(material, unreal.MaterialExpressionComponentMask, -480, 180)
    red.set_editor_property("r", True)
    EDIT.connect_material_expressions(vertex, "", red, "Input")
    lerp = expr(material, unreal.MaterialExpressionLinearInterpolate, -240, -80)
    EDIT.connect_material_expressions(rock, "", lerp, "A")
    EDIT.connect_material_expressions(sand, "", lerp, "B")
    EDIT.connect_material_expressions(red, "R", lerp, "Alpha")
    EDIT.connect_material_property(lerp, "", unreal.MaterialProperty.MP_BASE_COLOR)
    rough = expr(material, unreal.MaterialExpressionConstant, -280, 340)
    rough.set_editor_property("r", 0.86)
    EDIT.connect_material_property(rough, "", unreal.MaterialProperty.MP_ROUGHNESS)
    EDIT.recompile_material(material)
    LIB.save_loaded_asset(material)
    unreal.log("NEXUS erosion/deposition riverbank material ready: "+path)
    unreal.log_warning("Replace simple colors with photo-scanned rock and sand PBR maps before AAA visual signoff.")

if __name__ == "__main__":
    main()
