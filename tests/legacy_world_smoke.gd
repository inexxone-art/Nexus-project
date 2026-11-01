extends SceneTree
## Integration test: instantiate the actual Alpine world and simulate player actions.
func _initialize() -> void:
    call_deferred("_run")

func _fail(message: String) -> void:
    push_error("NEXUS V2.1 WORLD: " + message)
    quit(1)

func _run() -> void:
    var scene: PackedScene = load("res://scenes/main.tscn")
    if scene == null:
        _fail("Main scene unavailable")
        return
    var world: Node3D = scene.instantiate()
    root.add_child(world)
    await process_frame
    await process_frame
    if world.legacy == null or world.legacy_panel == null or world.legacy_panel.info == null:
        _fail("Legacy state/UI missing in real world")
        return
    var initial_money: int = world.coins
    world._on_legacy_action("property","garage")
    if world.coins != initial_money-850 or not world.legacy.properties.has("garage"):
        _fail("Property transaction did not update wallet atomically")
        return
    world._on_legacy_action("property","garage")
    if world.coins != initial_money-850:
        _fail("Duplicate property purchase charged money")
        return
    world._on_legacy_action("ship","scanner")
    if world.coins != initial_money-1550:
        _fail("Ship transaction incorrect")
        return
    var test_vehicle = world.vehicles[0]
    var tune_id: String = str(test_vehicle.definition.get("id",test_vehicle.category))
    world._on_legacy_action("tune",tune_id+"|motor")
    if int(test_vehicle.tune_motor) != 1:
        _fail("Real vehicle controller was not upgraded")
        return
    world._on_legacy_action("tune","nonexistent|motor")
    if world.legacy.vehicle_tuning.has("nonexistent"):
        _fail("Tuning unspawned vehicles bypassed ownership gate")
        return
    world.legacy.award_activity("story","Story test",110)
    world.save_state()
    var before: Dictionary = world.legacy.get_data()
    world.legacy.restore_data({})
    world.load_state()
    if not world.legacy.properties.has("garage") or world.legacy.tuning_for(tune_id)["motor"] != 1:
        _fail("World save/load lost property or vehicle upgrade")
        return
    if world.coins != initial_money-1550-175:
        _fail("World save/load lost wallet")
        return
    if int(world.vehicles[0].tune_motor) != 1:
        _fail("Loaded vehicle did not receive persisted tuning")
        return
    if world.legacy.events.size() < before.get("events",[]).size():
        _fail("World chronicle lost recorded events")
        return
    print("NEXUS V2.1 WORLD PASS: integrated UI, purchases, vehicle tuning, atomic wallet, save/load")
    world.queue_free()
    await process_frame
    quit(0)
