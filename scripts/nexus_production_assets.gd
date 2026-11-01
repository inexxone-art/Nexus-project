extends RefCounted
class_name NexusProductionAssets
## Verified CC0 models are downloaded during CI/build into assets/production.
## No download requests are made by the live game. Fallback models remain playable.
## Rendering-only GLB rotation never affects vehicle physics or collisions.
const HERO: Dictionary = {
    "CAR_041": {"path": "res://assets/production/vehicles/vortex_sport.glb", "scale": 1.0, "yaw": 90.0}, # Spectral GT RS points +X; NEXUS forward -Z
    "HELI_01": {"path": "res://assets/production/vehicles/alpin_h1.glb", "scale": 1.0, "yaw": 180.0}, # Source helicopter nose points +Z
    "EXC_02": {"path": "res://assets/production/vehicles/excavator_22t.glb", "scale": 1.0, "yaw": 180.0} # 22t model, when present; NOT a 14t scan
}

static func hero_path(vehicle_id: String) -> String:
    if not HERO.has(vehicle_id):
        return ""
    return str(HERO[vehicle_id]["path"])

static func has_production_mesh(vehicle_id: String) -> bool:
    var path: String = hero_path(vehicle_id)
    return path != "" and ResourceLoader.exists(path, "PackedScene")

static func create_hero_instance(vehicle_id: String) -> Node3D:
    var path: String = hero_path(vehicle_id)
    if path == "" or not ResourceLoader.exists(path, "PackedScene"):
        return null
    var loaded: Resource = ResourceLoader.load(path)
    if not (loaded is PackedScene):
        push_warning("NEXUS: production asset has no PackedScene: " + path)
        return null
    var scene: Node = (loaded as PackedScene).instantiate()
    if not (scene is Node3D):
        scene.queue_free()
        push_warning("NEXUS: GLB root must be Node3D: " + path)
        return null
    var root: Node3D = scene as Node3D
    root.name = "CC0 Production Model | " + vehicle_id
    var cfg: Dictionary = HERO[vehicle_id]
    root.rotation_degrees = Vector3(0.0, float(cfg.get("yaw", 0.0)), 0.0)
    root.scale = Vector3.ONE * float(cfg.get("scale", 1.0))
    return root

static func surface_texture(key: String, channel: String) -> Texture2D:
    # Restrict resource filenames to the seven vetted PBR sets.
    if key not in ["asphalt", "rock", "roof", "plaster", "wood", "grass", "concrete"]:
        return null
    if channel not in ["albedo", "normal", "roughness"]:
        return null
    for ext in ["png", "jpg"]:
        var path: String = "res://assets/production/materials/%s_%s.%s" % [key, channel, ext]
        if ResourceLoader.exists(path, "Texture2D"):
            return ResourceLoader.load(path) as Texture2D
    return null
