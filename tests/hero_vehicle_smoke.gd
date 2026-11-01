extends SceneTree
## Real scene assembly and articulated parts test for original hero model overlays.
const CATALOG = preload("res://scripts/nexus_vehicle_catalog.gd")
const VISUALS = preload("res://scripts/nexus_vehicle_visuals.gd")
const HERO = preload("res://scripts/nexus_hero_vehicles.gd")

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    for id in HERO.FEATURE_IDS:
        var record: Dictionary = CATALOG.by_id(str(id))
        if record.is_empty():
            push_error("Unknown hero vehicle: " + str(id))
            quit(1)
            return
        var vehicle := VISUALS.new()
        vehicle.set_vehicle(record, str(record.get("group", "")))
        root.add_child(vehicle)
        await process_frame
        # A source GLB deliberately replaces the procedural HERO details.
        if vehicle.imported_model != null:
            if vehicle.imported_model.find_children("*", "MeshInstance3D", true, false).is_empty():
                push_error("Imported vehicle contains no meshes: " + str(id))
                quit(7)
                return
            vehicle.animate_vehicle(0.016, 4.0, 0.2, true, 99.0)
            vehicle.queue_free()
            await process_frame
            continue
        var hero := vehicle.get_node_or_null("HERO DETAIL | original procedural craft")
        if hero == null or hero.get_child_count() < 20:
            push_error("Hero model assembly failed for " + str(id))
            quit(2)
            return
        if id == "HELI_01" and (vehicle.rotor_main == null or hero.get("rescue_searchlight") == null):
            push_error("Rescue rotor and light not installed")
            quit(3)
            return
        if id == "EXC_02" and (vehicle.boom_pivot == null or vehicle.bucket_pivot == null):
            push_error("Excavator booms not installed")
            quit(4)
            return
        vehicle.animate_vehicle(0.016, 4.0, 0.2, true, 99.0)
        vehicle.queue_free()
        await process_frame
    print("NEXUS V1.8 HERO VEHICLES PASS: sports car, rescue helicopter, excavator")
    quit(0)
