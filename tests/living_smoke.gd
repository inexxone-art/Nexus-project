extends SceneTree
## Run with Godot 4.4.1 --headless --path . --script res://tests/living_smoke.gd
const SIMULATION = preload("res://scripts/nexus_living_universe.gd")

func _initialize() -> void:
    call_deferred("_run")

func fail(reason: String) -> void:
    push_error("NEXUS LIVING SMOKE FAILED: " + reason)
    quit(1)

func _run() -> void:
    var sim: NexusLivingUniverse = SIMULATION.new()
    root.add_child(sim)
    if sim.REGIONS.size() != 6 or sim.INCIDENTS.size() != 6:
        fail("Wrong world region/event count")
        return
    for _tick in range(4):
        sim.advance(30.0)
    if sim.pending.is_empty():
        fail("First world incident was not generated")
        return
    var initial := sim.region_status("NEXUS City")
    if int(initial.get("stability", 100)) >= 85:
        fail("Regional incident has no consequence")
        return
    var rejected: Dictionary = sim.resolve(1, 0)
    if bool(rejected.get("ok", true)) or sim.pending.is_empty():
        fail("Unfunded decisions must be rejected without deleting incident")
        return
    var resolved: Dictionary = sim.resolve(2, 1000)
    if not bool(resolved.get("ok", false)) or sim.completed != 1:
        fail("Funded decision was not applied")
        return
    if sim.pending.size() != 0 or int(sim.factions["Zivilschutz"]) != 3:
        fail("Reputation or incident cleanup failed")
        return
    var snapshot := sim.get_data()
    var duplicate: NexusLivingUniverse = SIMULATION.new()
    duplicate.restore_data(snapshot)
    if duplicate.completed != 1 or duplicate.memories.size() != sim.memories.size():
        fail("Persistent memories changed after restore")
        return
    for _tick in range(4):
        duplicate.advance(30.0)
    if duplicate.pending.is_empty():
        fail("Subsequent incident did not spawn")
        return
    duplicate.free()
    sim.queue_free()
    print("NEXUS V1.4 LIVING SMOKE PASS: event chain, economy, faction consequences, persistence")
    quit(0)
