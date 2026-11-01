extends SceneTree
## Godot 4.4.1 deterministic runtime integration: zones, skyline, bridge and planet themes.
const MAP = preload("res://scripts/nexus_megamap_v27.gd")
const CITY = preload("res://scripts/nexus_planet_cities_v27.gd")
const WORLD = preload("res://scenes/main.tscn")

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var map: NexusMegaMapV27 = MAP.new()
    root.add_child(map)
    await process_frame
    if map.city_chunks.size() != 5 or map.building_count < 35 or map.bridge_deck == null:
        push_error("Missing megamap sectors / towers / collidable bridge")
        quit(1)
        return
    if not (map.bridge_deck is StaticBody3D):
        push_error("Bridge lacks a static collision body")
        quit(2)
        return
    for id in map.DISTRICTS.keys():
        var center: Vector3 = map.DISTRICTS[id]["center"]
        if map.get_region_at(center) != id:
            push_error("Broken region resolver: " + str(id))
            quit(3)
            return
    var actor := Node3D.new()
    root.add_child(actor)
    actor.position = Vector3(-135.0,0.0,86.0)
    map.set_actor(actor)
    map.set_graphics_tier(0)
    map._update_visibility()
    if not map.city_chunks["aurelia"].visible or map.city_chunks["stahlhafen"].visible:
        push_error("Mobile LOD near/far culling regression")
        quit(4)
        return
    for biome in CITY.CITY_STYLES.keys():
        var city: NexusPlanetCitiesV27 = CITY.new()
        root.add_child(city)
        city.configure(str(biome),2000,func(_x: float,_z: float) -> float: return 0.0)
        if city.structure_count != int(CITY.CITY_STYLES[biome]["count"]):
            push_error("Planet settlement missing: " + str(biome))
            quit(5)
            return
        city.queue_free()
    map.queue_free()
    actor.queue_free()
    var world = WORLD.instantiate()
    root.add_child(world)
    await process_frame
    await process_frame
    if world.mega_map == null or world.mega_map.bridge_deck == null:
        push_error("Mega map not integrated with Alpine main scene")
        quit(6)
        return
    print("PROJECT NEXUS V2.7 PASS | five varied zones, drivable bridge, six planetary settlement styles")
    quit(0)
