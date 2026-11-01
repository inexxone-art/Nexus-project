extends SceneTree
## Runtime regression for world districts/road graph, distance scenery, and no gameplay collision loss.
const SCENE = preload("res://scenes/main.tscn")
const LAYOUT = preload("res://scripts/nexus_world_structure.gd")
func _initialize() -> void:
    call_deferred("_test")
func _test() -> void:
    var expected := ["alpendorf", "rettungsbasis", "sektor31", "stadt", "bauhof", "industrie", "raumhafen"]
    var map: NexusWorldStructure = LAYOUT.new()
    root.add_child(map)
    await process_frame
    for district_id in expected:
        var route: PackedStringArray = map.find_road_route("garage", district_id)
        if route.size() < 2 or route[0] != "garage" or route[route.size()-1] != district_id:
            push_error("Disconnected world district: "+district_id)
            quit(1)
            return
        var p: Vector3 = map.DISTRICTS[district_id]["position"]
        if map.get_district_at(p) != district_id:
            push_error("Wrong world district lookup: "+district_id)
            quit(2)
            return
    if map.route_segments.size() != map.ROAD_EDGES.size() or map.detail_chunks.size() != 7:
        push_error("Incomplete road or district creation")
        quit(3)
        return
    var far := Node3D.new()
    map.add_child(far)
    map.bind_actor(far)
    map.apply_graphics_tier(0)
    for district_id in expected:
        if map.detail_chunks[district_id].visible:
            push_error("Mobile tier failed to cull optional detail")
            quit(4)
            return
    map.apply_graphics_tier(2)
    far.global_position = Vector3(5000,0,5000)
    map._update_visibility()
    for district_id in expected:
        if map.detail_chunks[district_id].visible:
            push_error("Far geometry failed to cull")
            quit(5)
            return
    map.queue_free()
    var world = SCENE.instantiate()
    root.add_child(world)
    await process_frame
    await process_frame
    if world.world_structure == null or world.world_structure.route_segments.size() == 0:
        push_error("New world structure not integrated with main scene")
        quit(6)
        return
    if world.stations.size() < 10 or world.vehicles.size() < 7:
        push_error("Mission facilities or starting vehicles were lost")
        quit(7)
        return
    print("NEXUS V2.5 WORLD STRUCTURE PASS: 7 districts, connected roads, LOD, old gameplay preserved")
    quit(0)
