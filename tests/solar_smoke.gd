extends SceneTree
## Godot: --headless --path . --script res://tests/solar_smoke.gd
const CAMPAIGN = preload("res://scripts/nexus_campaign.gd")

func _initialize() -> void:
    call_deferred("_run")

func _fail(text: String, code: int) -> void:
    push_error("SOLAR TEST FAILED: " + text)
    quit(code)

func _run() -> void:
    if CAMPAIGN.PLANETS.size() != 6:
        _fail("Six planets required",1)
        return
    var ids: Array[String] = []
    for planet in CAMPAIGN.PLANETS:
        var pid = str(planet["id"])
        if ids.has(pid):
            _fail("Planet identifiers must be unique",2)
            return
        ids.append(pid)
    for scene_name in ["res://scenes/starmap.tscn","res://scenes/planet.tscn"]:
        if load(scene_name) == null:
            _fail("Scene missing: " + scene_name,3)
            return
    var original = CAMPAIGN.load_data()
    var test_data = CAMPAIGN.default_data()
    test_data["planet"] = "nivora"
    CAMPAIGN.save_data(test_data)
    var planet_scene = load("res://scenes/planet.tscn")
    var planet = planet_scene.instantiate()
    root.add_child(planet)
    await process_frame
    await process_frame
    if planet.planet["id"] != "nivora" or planet.player == null:
        CAMPAIGN.save_data(original)
        _fail("Nivora landing not initialized",4)
        return
    if planet.height_at(0,0) > 0.01:
        CAMPAIGN.save_data(original)
        _fail("Landing position not flat",5)
        return
    planet.player.global_position = Vector3(-70,3,-50)
    planet._interact()
    if planet.mission_stage != 1 or planet.enemies.size() < 3:
        CAMPAIGN.save_data(original)
        _fail("Scan failed to begin combat encounter",6)
        return
    planet.kills = 3
    planet.player.global_position = Vector3(77,3,-66)
    planet._interact()
    if planet.mission_stage != 2:
        CAMPAIGN.save_data(original)
        _fail("Core extraction unsuccessful",7)
        return
    planet._choose(1)
    planet.player.global_position = Vector3(0,3,40)
    planet._interact()
    if planet.mission_stage != 3 or not CAMPAIGN.load_data()["completed"].has("nivora"):
        CAMPAIGN.save_data(original)
        _fail("Mission completion persistence failed",8)
        return
    planet.queue_free()
    await process_frame
    CAMPAIGN.save_data(original)
    print("NEXUS V1.2 SOLAR SMOKE PASS: 6 planets, expedition, enemies, extraction, save")
    quit(0)
