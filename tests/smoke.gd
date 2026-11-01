extends SceneTree
## Windows test: godot --headless --path . --script res://tests/smoke.gd
func _initialize() -> void:
    call_deferred("_start")

func fail(message: String, code: int) -> void:
    push_error("NEXUS TEST FAILED: " + message)
    quit(code)

func _start() -> void:
    var scene = load("res://scenes/main.tscn")
    if scene == null:
        fail("scene missing", 1)
        return
    var world = scene.instantiate()
    root.add_child(world)
    await process_frame
    await process_frame
    if world.player == null or world.vehicles.size() != 7:
        fail("player or 7 vehicles missing", 2)
        return
    if world.drone == null or world.minimap == null or world.world_clock == null:
        fail("FPV, map or weather missing", 3)
        return
    if world.stations.size() != 10:
        fail("expected 10 stations, got %d" % world.stations.size(), 4)
        return
    # Oil extraction and refining use the actual interaction routing.
    world.player.global_position = Vector3(-96, 0.2, 35)
    world.resource_cooldown = 0.0
    world._interact()
    if world.oil != 2:
        fail("oil extraction", 5)
        return
    world.oil = 3
    world.player.global_position = Vector3(-99, 0.2, 65)
    world._interact()
    if world.oil != 0 or world.refined_fuel != 2:
        fail("oil refining", 6)
        return
    world.player.global_position = Vector3(6, 0.2, 95)
    world.resource_cooldown = 0
    world._interact()
    if world.crops != 3:
        fail("farming", 7)
        return
    world.player.global_position = Vector3(-43, 0.2, -62)
    world._interact()
    if world.paper != 3:
        fail("paper mill", 8)
        return
    world.player.global_position = Vector3(-120, 0.2, 117)
    world.resource_cooldown = 0
    world._interact()
    if world.meteor != 1:
        fail("meteor resource", 9)
        return
    world._toggle_drone()
    if not world.drone_active or not world.drone.controlled:
        fail("drone launch", 10)
        return
    world._toggle_drone()
    if world.drone_active or not world.player.active:
        fail("drone exit", 11)
        return
    var saved_time = world.world_clock.hour
    world.world_clock.skip_hours(2.0)
    if absf(world.world_clock.hour - saved_time - 2.0) > 0.2:
        fail("world time", 12)
        return
    world._spawn_log(Vector3(-45, 0.65, -28))
    var cash_before = world.coins
    world._sell_logs()
    if world.coins != cash_before + 135:
        fail("sawmill", 13)
        return
    world._spawn_build(0, Vector3(32, 0, 32), 0.0)
    if world.constructions.size() != 1:
        fail("construction", 14)
        return
    world.save_state()
    if not FileAccess.file_exists(world.SAVE_PATH):
        fail("save file missing", 15)
        return
    world.crops = 0
    world.load_state()
    if world.crops != 3 or world.constructions.size() != 1:
        fail("save/load persistence", 16)
        return
    if world.landscape == null or world.story == null:
        fail("V1.1 landscape and story nodes", 17)
        return
    world.story.restore_data({"stage": 0})
    var task0: Dictionary = world.story.interact(Vector3(74, 0, 72))
    if not bool(task0.get("handled", false)) or world.story.stage != 1:
        fail("V1.1 story rescue activation", 18)
        return
    var task1: Dictionary = world.story.interact(Vector3(47, 0, 32))
    if int(task1.get("money", 0)) != 400 or world.story.stage != 2:
        fail("V1.1 story rescue completion", 19)
        return
    world.story.interact(Vector3(117, 0, 82))
    if world.story.decide(1).is_empty() or world.story.final_choice != 1:
        fail("V1.1 branching decision", 20)
        return
    var task3: Dictionary = world.story.interact(Vector3(-59, 0, 87))
    if not bool(task3.get("handled", false)) or world.story.stage != 4:
        fail("V1.1 story prologue end", 21)
        return
    world.save_state()
    world.story.stage = 0
    world.load_state()
    if world.story.stage != 4 or world.story.memories.size() < 3:
        fail("V1.1 story persistence", 22)
        return
    print("NEXUS V1.1 SMOKE PASS: existing systems + procedural landscape, 4-stage narrative, choice, story persistence")
    quit(0)
