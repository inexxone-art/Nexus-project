"""Creates a Fresnel-colored river material in the actual Unreal Editor.
Place under Unreal/NEXUS_UE5/Scripts and run Tools > Execute Python Script.
It is an engine-native physically-inspired fallback, not a scanned water shader.
"""
import unreal

TOOLS = unreal.AssetToolsHelpers.get_asset_tools()
LIB = unreal.EditorAssetLibrary
EDIT = unreal.MaterialEditingLibrary
PATH = "/Game/AAA/Materials"
NAME = "M_NexusRiverWater"

def expression(material, kind, x, y):
    node = EDIT.create_material_expression(material, kind, x, y)
    if node is None:
        raise RuntimeError(f"Failed creating material node {kind}")
    return node

def color(material, rgb, x, y):
    node = expression(material, unreal.MaterialExpressionConstant3Vector, x, y)
    node.set_editor_property("constant", unreal.LinearColor(*rgb, 1.0))
    return node

def scalar(material, value, x, y):
    node = expression(material, unreal.MaterialExpressionConstant, x, y)
    node.set_editor_property("r", value)
    return node

def main():
    target = f"{PATH}/{NAME}"
    if LIB.does_asset_exist(target):
        unreal.log(f"NEXUS river already exists, preserving custom edits: {target}")
        return
    material = TOOLS.create_asset(NAME, PATH, unreal.Material, unreal.MaterialFactoryNew())
    if not material:
        raise RuntimeError("Failed to create Unreal river material")
    material.set_editor_property("two_sided", True)
    material.set_editor_property("blend_mode", unreal.BlendMode.BLEND_TRANSLUCENT)

    deep = color(material, (.013, .095, .115), -700, -320)
    shallow = color(material, (.055, .19, .20), -700, -90)
    fresnel = expression(material, unreal.MaterialExpressionFresnel, -680, 135)
    mix = expression(material, unreal.MaterialExpressionLinearInterpolate, -270, -100)
    EDIT.connect_material_expressions(deep, "", mix, "A")
    EDIT.connect_material_expressions(shallow, "", mix, "B")
    EDIT.connect_material_expressions(fresnel, "", mix, "Alpha")
    EDIT.connect_material_property(mix, "", unreal.MaterialProperty.MP_BASE_COLOR)

    rough = scalar(material, .085, -390, 325)
    EDIT.connect_material_property(rough, "", unreal.MaterialProperty.MP_ROUGHNESS)
    opacity = scalar(material, .79, -390, 465)
    EDIT.connect_material_property(opacity, "", unreal.MaterialProperty.MP_OPACITY)
    metallic = scalar(material, 0.0, -400, 595)
    EDIT.connect_material_property(metallic, "", unreal.MaterialProperty.MP_METALLIC)
    EDIT.recompile_material(material)
    LIB.save_loaded_asset(material)
    unreal.log(f"NEXUS PBR-inspired river material ready: {target}")
    unreal.log_warning("For AAA approval add real normal/wave textures, flow-map motion and shore foam.")

if __name__ == "__main__":
    main()
