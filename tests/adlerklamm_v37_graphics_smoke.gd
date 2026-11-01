extends SceneTree
## V3.7 graphics integration test: REAL scene and actual Godot resource import.
## This validates scene wiring and material usage, NOT visual AAA fidelity.
func _initialize() -> void:
    call_deferred("_verify")

func fail(message: String,exit_code: int) -> void:
    push_error("NEXUS V3.7 GRAPHICS | "+message)
    quit(exit_code)

func _verify() -> void:
    var scene: PackedScene = load("res://scenes/main.tscn")
    if scene == null:
        fail("Main scene missing",1)
        return
    var world: Node3D = scene.instantiate()
    root.add_child(world)
    await process_frame
    await process_frame
    var graphics: NexusAdlerklammGraphicsV37 = world.graphics_v37
    if graphics == null:
        fail("V3.7 world graphics not instantiated",2)
        return
    if graphics.cliff_count != 2 or graphics.pine_count != 490 or graphics.response_vehicle_count != 3:
        fail("Scenic cliffs/forest/rescue convoy incomplete",3)
        return
    if graphics.ground_material == null or graphics.ground_material.shader == null:
        fail("World terrain is still simple vertex colors instead of PBR blend shader",4)
        return
    if graphics.canyon_river_material == null or graphics.canyon_river_material.shader == null:
        fail("Animated V3.7 river shader not connected",5)
        return
    if not graphics.sky_preset_applied:
        fail("Graphics render settings not connected to world environment",6)
        return
    var bridge: NexusAdlerklammDisaster = world.mega_map.canyon_disaster
    if bridge == null or bridge.bus == null:
        fail("Rescue bus rigid body missing",7)
        return
    var bus_art: NexusBusArtV37
    for child in bridge.bus.get_children():
        if child is NexusBusArtV37:
            bus_art = child
    if bus_art == null or bus_art.decorative_panels < 45:
        fail("Detailed bus art not attached to the physical bus",8)
        return
    if not bridge.start_disaster() or bridge.pieces.size() != 12:
        fail("Disaster no longer works with upgraded graphics",9)
        return
    for section in bridge.pieces:
        var found := false
        for child in section.get_children():
            if child is NexusBridgeFractureArtV37:
                if child.reinforcement_count == 18 and child.fracture_meshes == 2:
                    found = true
        if not found:
            fail("Bridges lack exposed reinforcing steel and fracture faces",10)
            return
    print("NEXUS V3.7 GRAPHICS PASS | PBR ground/river, cliffs, 490 firs, emergency convoy, bus and 12 reinforced spans")
    world.queue_free()
    await process_frame
    quit(0)
