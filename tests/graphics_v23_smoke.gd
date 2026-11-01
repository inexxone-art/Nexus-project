extends SceneTree
## Tests actual Godot resource loading, procedural fallback and wetness logic.
const WORLD = preload("res://scenes/main.tscn")
const ASSETS = preload("res://scripts/nexus_production_assets.gd")

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    if ASSETS.hero_path("CAR_041") == "" or ASSETS.hero_path("EXC_02") == "":
        push_error("Missing production asset contract")
        quit(1)
        return
    var world = WORLD.instantiate()
    root.add_child(world)
    await process_frame
    await process_frame
    if world.weather_surface == null or world.weather_surface.road == null:
        push_error("Wet road shader was not mounted")
        quit(2)
        return
    var buildings := 0
    for house in world.root_objects.get_children():
        if house.name.begins_with("Alpendorf Haus "):
            buildings += 1
            var roof_count := 0
            for item in house.get_children():
                if item is Node3D and absf((item as Node3D).rotation.z) > 0.01:
                    roof_count += 1
            if roof_count != 2:
                push_error("Missing two rotated roof panels for " + house.name + "; count=" + str(roof_count))
                quit(3)
                return
    if buildings != 9:
        push_error("Expected nine alpine houses")
        quit(4)
        return
    world.world_clock.weather = 2
    world.weather_surface._process(8.0)
    if world.weather_surface.wetness < 0.5:
        push_error("Rain does not increase wetness")
        quit(5)
        return
    world.world_clock.weather = 0
    world.weather_surface._process(8.0)
    if world.weather_surface.wetness >= 0.99:
        push_error("Road did not dry after rain")
        quit(6)
        return
    print("NEXUS V2.3 GRAPHICS SMOKE PASS: hero imports optional, 9 pitched alpine houses, wet weather shader")
    quit(0)
