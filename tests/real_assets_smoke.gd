extends SceneTree
## Runs after the GitHub Actions downloader and headless Godot --editor --import.
const MODELS = preload("res://scripts/nexus_production_assets.gd")
const FLEET = preload("res://scripts/nexus_vehicle_catalog.gd")

func _initialize() -> void:
    call_deferred("_test")

func _test() -> void:
    var required := ["CAR_041", "HELI_01"]
    for vehicle_id in required:
        if not MODELS.has_production_mesh(vehicle_id):
            push_error("Expected CC0 production model missing in imported build: " + vehicle_id)
            quit(1)
            return
        var instance: Node3D = MODELS.create_hero_instance(vehicle_id)
        if instance == null:
            push_error("Could not instantiate CC0 GLB: " + vehicle_id)
            quit(2)
            return
        root.add_child(instance)
        await process_frame
        var mesh_count: int = 0
        for descendant in instance.find_children("*", "MeshInstance3D", true, false):
            mesh_count += 1
        if mesh_count == 0:
            push_error("Imported GLB contains no MeshInstance3D: " + vehicle_id)
            quit(3)
            return
        print("NEXUS ASSET TEST: %s => %d visible meshes" % [vehicle_id, mesh_count])
        instance.queue_free()
    for category in ["roof", "rock", "grass", "asphalt", "wood", "plaster", "concrete"]:
        for channel in ["albedo", "normal", "roughness"]:
            var tex: Texture2D = MODELS.surface_texture(category, channel)
            if tex == null or tex.get_width() < 512:
                push_error("Imported PBR material is absent or too small: %s/%s" % [category, channel])
                quit(4)
                return
    print("NEXUS REAL-ASSET IMPORT PASS: CC0 car, helicopter, 7x3 Poly Haven textures")
    quit(0)
