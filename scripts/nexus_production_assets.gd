extends RefCounted
class_name NexusProductionAssets
## Plug-in point for ORIGINAL or properly licensed GLB assets.
## This does not download assets or claim that production meshes are included.
## Convention: glTF meshes use metres and -Z as the vehicle front direction.

const HERO: Dictionary = {
    "CAR_041": {"path": "res://assets/production/vehicles/vortex_sport.glb", "scale": 1.0},
    "HELI_01": {"path": "res://assets/production/vehicles/alpin_h1.glb", "scale": 1.0},
    "EXC_02": {"path": "res://assets/production/vehicles/excavator_14t.glb", "scale": 1.0}
}

static func hero_path(vehicle_id: String) -> String:
    if not HERO.has(vehicle_id):
        return ""
    return str(HERO[vehicle_id]["path"])

static func has_production_mesh(vehicle_id: String) -> bool:
    var path := hero_path(vehicle_id)
    return path != "" and ResourceLoader.exists(path, "PackedScene")

static func create_hero_instance(vehicle_id: String) -> Node3D:
    var path := hero_path(vehicle_id)
    if path == "" or not ResourceLoader.exists(path, "PackedScene"):
        return null
    var resource := ResourceLoader.load(path) as PackedScene
    if resource == null:
        return null
    var root := resource.instantiate() as Node3D
    if root == null:
        return null
    root.name = "PRODUCTION GLB | " + vehicle_id
    root.scale = Vector3.ONE * float(HERO[vehicle_id].get("scale", 1.0))
    return root

static func surface_texture(key: String, channel: String) -> Texture2D:
    # Strict whitelist prevents arbitrary res:// path injection via untrusted names.
    if key not in ["asphalt", "rock", "roof", "plaster", "wood", "grass", "concrete"]:
        return null
    if channel not in ["albedo", "normal", "roughness", "metallic"]:
        return null
    var path := "res://assets/production/materials/%s_%s.png" % [key, channel]
    if not ResourceLoader.exists(path):
        return null
    return ResourceLoader.load(path) as Texture2D
