extends SceneTree
## Functional check of V3.4 physics event, serialization and reconstruction.
const MAP = preload("res://scripts/nexus_megamap_v27.gd")

func _initialize() -> void:
    call_deferred("_run")

func _fail(msg: String, code: int) -> void:
    push_error("ADLERKLAMM V3.4: "+msg)
    quit(code)

func _run() -> void:
    var map: NexusMegaMapV27 = MAP.new()
    root.add_child(map)
    await process_frame
    var skyline: NexusIndustrySkylineV34 = null
    for child in map.city_chunks["canyon"].get_children():
        if child is NexusIndustrySkylineV34:
            skyline = child
    if skyline == null or skyline.tower_count != 6 or skyline.window_count < 400:
        _fail("Industrial skyline with instanced facade windows missing",9)
        return
    var art: NexusAdlerklammEnvironmentV35 = null
    for child in map.get_children():
        if child is NexusAdlerklammEnvironmentV35:
            art = child
    if art == null or art.rock_count != 130 or art.river == null:
        _fail("V3.5 photo-rock river landscape not loaded",10)
        return
    var incident: NexusAdlerklammDisaster = map.canyon_disaster
    if incident == null or incident.bus == null or map.bridge_deck == null:
        _fail("Bridge scenario not attached to existing megamap",1)
        return
    if incident.stage != "ready" or incident.PIECE_COUNT != 12:
        _fail("Initial bridge state invalid",2)
        return
    if not incident.start_disaster() or incident.pieces.size() != 12:
        _fail("Bridge segments not spawned",3)
        return
    if incident.start_disaster():
        _fail("Double-start unexpectedly permitted",4)
        return
    incident._process(4.0)
    if incident.released.size() != 12 or incident.bus.freeze:
        _fail("Physical spans or bus did not detach",5)
        return
    incident._process(6.0)
    if incident.stage != "aftermath" or not incident.get_data().get("bridge_destroyed",false):
        _fail("Aftermath is not persistent",6)
        return
    if not incident.rebuild_bridge() or incident.stage != "ready" or incident.pieces.size() != 0:
        _fail("Rebuild did not restore the bridge",7)
        return
    incident.restore_data({"bridge_destroyed":true})
    if incident.stage != "aftermath" or incident.released.size() != 12:
        _fail("Destroyed bridge did not reload",8)
        return
    map.queue_free()
    print("NEXUS V3.4 PASS | bus fall, 12 breakaway spans, save/load and rebuild")
    quit(0)
