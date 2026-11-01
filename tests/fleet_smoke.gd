extends SceneTree
## Intended for headless Godot 4.4.1 CI; not a substitute for real rendering/gameplay tests.
const CATALOG = preload("res://scripts/nexus_vehicle_catalog.gd")
const LORE = preload("res://scripts/nexus_lore.gd")
const VEHICLE = preload("res://scripts/vehicle.gd")

func _initialize() -> void:
    call_deferred("_run")

func _assert(condition: bool, message: String) -> void:
    if not condition:
        push_error("FLEET SMOKE FAIL: " + message)
        quit(1)

func _run() -> void:
    var entries = CATALOG.all()
    _assert(entries.size() == 123, "Expected 123 vehicle definitions")
    var counts = {}
    var ids = {}
    for record in entries:
        counts[record["group"]] = int(counts.get(record["group"], 0)) + 1
        _assert(not ids.has(record["id"]), "Duplicate id " + str(record["id"]))
        ids[record["id"]] = true
        _assert(float(record["top_kmh"]) > 5.0, "Bad speed")
        _assert(float(record["length"]) > 2.0, "Bad length")
    for label in {"Autos":70,"Panzer":20,"Helikopter":10,"Bagger":3,"Nutzfahrzeuge":20}:
        _assert(int(counts.get(label,0)) == int({"Autos":70,"Panzer":20,"Helikopter":10,"Bagger":3,"Nutzfahrzeuge":20}[label]), label)
    for pid in ["terra","sahra","nivora","vesper","ignis","umbra"]:
        _assert(LORE.info(pid).has("choice_a"), "No story decision for " + pid)
    var example = VEHICLE.new()
    example.configure(CATALOG.by_id("HELI_01"))
    _assert(example.category == "Helikopter", "Helicopter category mapping")
    _assert(example.model_name == "Alpin H1", "Model name mapping")
    example.free()
    print("NEXUS FLEET SMOKE PASS: 123 variants, 6 planet story arcs")
    quit()
