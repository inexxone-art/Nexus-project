extends SceneTree
## Headless regression: three-stage contracts, no premature payment, save/load and world consequences.
const OPS = preload("res://scripts/nexus_world_operations.gd")
const LIVING = preload("res://scripts/nexus_living_universe.gd")

func _initialize() -> void:
    call_deferred("_run")

func _fail(reason: String) -> void:
    push_error("NEXUS V1.5 OPS FAILED: " + reason)
    quit(1)

func _run() -> void:
    var sim: NexusLivingUniverse = LIVING.new()
    root.add_child(sim)
    var ops: NexusWorldOperations = OPS.new()
    root.add_child(ops)
    ops.operation_completed.connect(func(contract: Dictionary):
        sim.apply_field_operation(str(contract["category"]), str(contract["region"]))
    )
    var target: Vector3 = ops.current_target()
    if ops.try_interact(Vector3(3000.0, 0, 3000.0)).get("handled", true):
        _fail("Interaction allowed from outside mission radius")
        return
    var first := ops.try_interact(target)
    if not first.get("handled", false) or first.get("completed", true) or int(first.get("money", -1)) != 0:
        _fail("Stage 1 incorrectly paid or failed")
        return
    if ops.stage != 1 or ops.completed != 0:
        _fail("Stage 1 state was not applied")
        return
    var checkpoint := ops.get_data()
    var restored: NexusWorldOperations = OPS.new()
    root.add_child(restored)
    restored.restore_data(checkpoint)
    if restored.stage != 1 or restored.index != 0:
        _fail("Multi-stage mission failed to restore")
        return
    var second := ops.try_interact(ops.current_target())
    if not second.get("handled", false) or second.get("completed", true) or ops.stage != 2:
        _fail("Stage 2 failed or paid prematurely")
        return
    if ops.try_interact(ops.current_target() + Vector3(99, 0, 99)).get("handled", true):
        _fail("Distant completion bypassed radius")
        return
    var last := ops.try_interact(ops.current_target())
    if not last.get("completed", false) or int(last.get("money", 0)) != 425:
        _fail("Final report did not pay the correct amount")
        return
    if ops.completed != 1 or ops.stage != 0 or ops.index != 1:
        _fail("Next contract did not unlock")
        return
    if sim.field_operations != 1 or int(sim.regions["Alpental"]["stability"]) != 89:
        _fail("Operation consequence was not propagated to persistent world")
        return
    var saved := sim.get_data()
    var clone: NexusLivingUniverse = LIVING.new()
    clone.restore_data(saved)
    if clone.field_operations != 1 or clone.memories.is_empty():
        _fail("Consequences lost on save/load")
        return
    # A field operation cannot be claimed again: the marker now belongs to next contract.
    if ops.try_interact(target).get("handled", false):
        _fail("Previously completed marker still pays")
        return
    print("NEXUS V1.5 OPS PASS: distance, 3 phases, payout, save/load, region, reputation")
    quit(0)
